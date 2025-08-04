from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from app.database import get_db
from app.models.user import User
from app.models.audio import AudioFile
from app.schemas.audio import AudioFileResponse, AudioProcessRequest, AudioProcessResponse
from app.utils.dependencies import get_current_active_user
from app.services.storage import save_uploaded_file
from app.services.stt import transcribe_audio, get_audio_duration

router = APIRouter()


@router.post("/upload", response_model=AudioFileResponse)
async def upload_audio_file(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """오디오 파일 업로드"""
    
    print(f"🔍 받은 파일: {file.filename}, Content-Type: {file.content_type}")
    
    # 파일 타입 검증
    if not file.content_type or not file.content_type.startswith("audio/"):
        print(f"❌ 잘못된 파일 타입: {file.content_type}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only audio files are allowed"
        )
    
    try:
        # 파일 저장
        file_path, file_name, file_size = await save_uploaded_file(file, str(current_user.id))
        
        # 오디오 길이 추정
        duration = get_audio_duration(file_path)
        
        # 데이터베이스에 저장
        audio_file = AudioFile(
            user_id=current_user.id,
            file_path=file_path,
            file_name=file_name,
            file_size=file_size,
            duration=duration,
            processing_status="uploaded"
        )
        
        db.add(audio_file)
        await db.commit()
        await db.refresh(audio_file)
        
        return AudioFileResponse(
            id=str(audio_file.id),
            user_id=str(audio_file.user_id),
            file_name=audio_file.file_name,
            file_size=audio_file.file_size,
            duration=audio_file.duration,
            transcript_text=audio_file.transcript_text,
            processing_status=audio_file.processing_status,
            created_at=audio_file.created_at
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to upload file: {str(e)}"
        )


@router.post("/process", response_model=AudioProcessResponse)
async def process_audio_file(
    request: AudioProcessRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """오디오 파일을 STT로 처리"""
    
    # 오디오 파일 조회
    result = await db.execute(
        select(AudioFile).where(
            AudioFile.id == request.audio_id,
            AudioFile.user_id == current_user.id
        )
    )
    audio_file = result.scalar_one_or_none()
    
    if not audio_file:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Audio file not found"
        )
    
    if audio_file.processing_status == "processing":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Audio file is already being processed"
        )
    
    try:
        print(f"🔍 오디오 처리 시작: {audio_file.id}")
        
        # 처리 상태 업데이트
        audio_file.processing_status = "processing"
        await db.commit()
        print(f"🔍 처리 상태를 'processing'으로 업데이트")
        
        # STT 처리
        print(f"🔍 STT 처리 시작: {audio_file.file_path}")
        transcript_text = await transcribe_audio(audio_file.file_path)
        
        if not transcript_text:
            print("❌ STT 처리 실패: transcript_text가 None")
            audio_file.processing_status = "failed"
            await db.commit()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to transcribe audio"
            )
        
        print(f"✅ STT 처리 성공: {len(transcript_text)} 문자")
        
        # GPT로 레시피 생성
        print(f"🔍 GPT 레시피 생성 시작")
        from app.services.gpt import organize_recipe_from_text
        from app.models.recipe import Recipe
        
        recipe_data = await organize_recipe_from_text(transcript_text)
        recipe_id = None
        
        if recipe_data:
            print(f"✅ GPT 레시피 생성 성공: {recipe_data['title']}")
            
            # 레시피 데이터베이스에 저장
            recipe = Recipe(
                user_id=current_user.id,
                source_audio_id=audio_file.id,
                title=recipe_data.get("title", "정리된 레시피"),
                description=recipe_data.get("description", ""),
                ingredients=recipe_data.get("ingredients", []),
                steps=recipe_data.get("steps", []),
                tips=recipe_data.get("tips", ""),
                servings=recipe_data.get("servings", "2-3인분"),
                cooking_time=recipe_data.get("cooking_time", "30분"),
                difficulty=recipe_data.get("difficulty", "보통"),
                category=recipe_data.get("category", "한식")
            )
            
            db.add(recipe)
            await db.commit()
            await db.refresh(recipe)
            recipe_id = str(recipe.id)
            print(f"✅ 레시피 데이터베이스 저장 완료: {recipe_id}")
        else:
            print("❌ GPT 레시피 생성 실패")
        
        # 결과 저장
        audio_file.transcript_text = transcript_text
        audio_file.processing_status = "completed"
        await db.commit()
        print(f"✅ 처리 완료, 상태를 'completed'로 업데이트")
        
        return AudioProcessResponse(
            audio_id=str(audio_file.id),
            transcript_text=transcript_text,
            processing_status="completed",
            recipe_id=recipe_id
        )
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ 오디오 처리 중 예외 발생:")
        print(f"   오류 타입: {type(e).__name__}")
        print(f"   오류 메시지: {str(e)}")
        import traceback
        print(f"   스택 트레이스: {traceback.format_exc()}")
        
        audio_file.processing_status = "failed"
        await db.commit()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Processing failed: {str(e)}"
        )


@router.get("/", response_model=List[AudioFileResponse])
async def get_user_audio_files(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """사용자의 오디오 파일 목록 조회"""
    
    result = await db.execute(
        select(AudioFile)
        .where(AudioFile.user_id == current_user.id)
        .order_by(AudioFile.created_at.desc())
    )
    audio_files = result.scalars().all()
    
    return [
        AudioFileResponse(
            id=str(af.id),
            user_id=str(af.user_id),
            file_name=af.file_name,
            file_size=af.file_size,
            duration=af.duration,
            transcript_text=af.transcript_text,
            processing_status=af.processing_status,
            created_at=af.created_at
        )
        for af in audio_files
    ]


@router.get("/{audio_id}/transcript")
async def get_audio_transcript(
    audio_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """오디오 파일의 변환된 텍스트 조회"""
    
    result = await db.execute(
        select(AudioFile).where(
            AudioFile.id == audio_id,
            AudioFile.user_id == current_user.id
        )
    )
    audio_file = result.scalar_one_or_none()
    
    if not audio_file:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Audio file not found"
        )
    
    return {
        "audio_id": str(audio_file.id),
        "transcript_text": audio_file.transcript_text,
        "processing_status": audio_file.processing_status
    }