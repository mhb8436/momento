import os
import aiofiles
import asyncio
from typing import List, AsyncGenerator
from fastapi import UploadFile, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
import tempfile
import shutil
from pathlib import Path

from app.models.audio import AudioFile
from app.models.user import User


class AudioProcessingService:
    """대용량 오디오 파일 처리 서비스"""
    
    MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB
    MAX_CHUNK_SIZE = 1024 * 1024      # 1MB per chunk
    SUPPORTED_FORMATS = {'.wav', '.mp3', '.aac', '.m4a', '.ogg'}
    
    def __init__(self):
        self.temp_dir = Path(tempfile.gettempdir()) / "momento_audio"
        self.temp_dir.mkdir(exist_ok=True)
    
    async def validate_audio_file(self, file: UploadFile) -> None:
        """오디오 파일 유효성 검사"""
        # 파일 확장자 검사
        file_ext = Path(file.filename or "").suffix.lower()
        if file_ext not in self.SUPPORTED_FORMATS:
            raise HTTPException(
                status_code=400,
                detail=f"지원하지 않는 파일 형식입니다. 지원 형식: {', '.join(self.SUPPORTED_FORMATS)}"
            )
        
        # 파일 크기 사전 검사 (Content-Length 헤더 기반)
        if hasattr(file, 'size') and file.size and file.size > self.MAX_FILE_SIZE:
            raise HTTPException(
                status_code=413,
                detail=f"파일 크기가 너무 큽니다. 최대 {self.MAX_FILE_SIZE // (1024*1024)}MB까지 지원됩니다."
            )
    
    async def process_chunked_upload(
        self,
        file: UploadFile,
        user: User,
        db: AsyncSession,
        chunk_callback: callable = None
    ) -> AudioFile:
        """청크 단위로 오디오 파일 업로드 처리"""
        
        await self.validate_audio_file(file)
        
        # 임시 파일 생성
        temp_file_path = self.temp_dir / f"temp_{user.id}_{file.filename}"
        total_size = 0
        
        try:
            # 청크 단위로 파일 저장
            async with aiofiles.open(temp_file_path, 'wb') as temp_file:
                async for chunk in self._read_chunks(file):
                    total_size += len(chunk)
                    
                    # 파일 크기 제한 검사
                    if total_size > self.MAX_FILE_SIZE:
                        raise HTTPException(
                            status_code=413,
                            detail="파일 크기 제한을 초과했습니다."
                        )
                    
                    await temp_file.write(chunk)
                    
                    # 진행률 콜백 호출
                    if chunk_callback:
                        await chunk_callback(len(chunk), total_size)
            
            # 오디오 파일 메타데이터 추출
            metadata = await self._extract_audio_metadata(temp_file_path)
            
            # 파일 크기가 크면 자동 압축
            if total_size > 10 * 1024 * 1024:  # 10MB 이상
                print(f"🔄 파일 크기가 큼 ({total_size:,} bytes), 압축 시도")
                compressed_path = await self.compress_audio_file(temp_file_path)
                
                if compressed_path != temp_file_path:  # 압축이 실제로 수행됨
                    # 압축된 파일의 메타데이터 다시 추출
                    metadata = await self._extract_audio_metadata(compressed_path)
                    total_size = compressed_path.stat().st_size
                    temp_file_path = compressed_path
            
            # 파일을 영구 저장소로 이동
            final_path = await self._move_to_permanent_storage(
                temp_file_path, user.id, file.filename or "audio"
            )
            
            # 데이터베이스에 저장
            audio_file = AudioFile(
                user_id=user.id,
                filename=file.filename or "audio",
                file_path=str(final_path),
                file_size=total_size,
                duration=metadata.get('duration', 0),
                format=metadata.get('format', 'unknown'),
                sample_rate=metadata.get('sample_rate', 0),
                channels=metadata.get('channels', 0)
            )
            
            db.add(audio_file)
            await db.commit()
            await db.refresh(audio_file)
            
            return audio_file
            
        except Exception as e:
            # 임시 파일 정리
            if temp_file_path.exists():
                temp_file_path.unlink()
            raise
    
    async def _read_chunks(self, file: UploadFile) -> AsyncGenerator[bytes, None]:
        """파일을 청크 단위로 읽기"""
        while True:
            chunk = await file.read(self.MAX_CHUNK_SIZE)
            if not chunk:
                break
            yield chunk
    
    async def _extract_audio_metadata(self, file_path: Path) -> dict:
        """오디오 파일 메타데이터 추출"""
        try:
            import librosa
            import soundfile as sf
            
            # librosa로 오디오 파일 정보 추출
            try:
                # 오디오 파일 로드 (메타데이터만)
                info = sf.info(str(file_path))
                duration = info.duration
                sample_rate = info.samplerate
                channels = info.channels
                
                print(f"📊 메타데이터 추출 성공: {duration:.1f}초, {sample_rate}Hz, {channels}ch")
                
                return {
                    'duration': duration,
                    'format': file_path.suffix[1:] if file_path.suffix else 'unknown',
                    'sample_rate': sample_rate,
                    'channels': channels
                }
            except Exception as librosa_error:
                print(f"librosa 메타데이터 추출 실패: {librosa_error}")
                # 기본값 반환
                return {
                    'duration': 0,
                    'format': file_path.suffix[1:] if file_path.suffix else 'unknown',
                    'sample_rate': 44100,
                    'channels': 2
                }
        except ImportError:
            print("librosa 또는 soundfile이 설치되지 않음")
            return {
                'duration': 0,
                'format': file_path.suffix[1:] if file_path.suffix else 'unknown',
                'sample_rate': 44100,
                'channels': 2
            }
        except Exception as e:
            print(f"메타데이터 추출 실패: {e}")
            return {}
    
    async def _move_to_permanent_storage(
        self, 
        temp_path: Path, 
        user_id: str, 
        filename: str
    ) -> Path:
        """임시 파일을 영구 저장소로 이동"""
        # 영구 저장소 경로 생성
        storage_dir = Path("uploads/audio") / str(user_id)
        storage_dir.mkdir(parents=True, exist_ok=True)
        
        # 고유한 파일명 생성
        timestamp = int(asyncio.get_event_loop().time())
        file_ext = Path(filename).suffix
        final_filename = f"{timestamp}_{filename}"
        final_path = storage_dir / final_filename
        
        # 파일 이동
        shutil.move(str(temp_path), str(final_path))
        
        return final_path
    
    async def compress_audio_file(self, file_path: Path) -> Path:
        """오디오 파일 압축 (pydub 사용)"""
        try:
            from pydub import AudioSegment
            import asyncio
            
            print(f"🔄 오디오 압축 시작: {file_path}")
            
            # 압축된 파일 경로 생성
            compressed_path = file_path.with_name(f"compressed_{file_path.name}")
            if compressed_path.suffix.lower() not in ['.mp3', '.aac', '.m4a']:
                compressed_path = compressed_path.with_suffix('.mp3')
            
            # 비동기로 압축 수행 (CPU 집약적 작업)
            def _compress_sync():
                try:
                    # 원본 오디오 로드
                    audio = AudioSegment.from_file(str(file_path))
                    
                    # 압축 설정 적용
                    # 1. 샘플 레이트 다운샘플링 (44.1kHz -> 16kHz)
                    if audio.frame_rate > 16000:
                        audio = audio.set_frame_rate(16000)
                    
                    # 2. 모노로 변환 (스테레오 -> 모노)
                    if audio.channels > 1:
                        audio = audio.set_channels(1)
                    
                    # 3. 비트레이트 제한하여 내보내기
                    if compressed_path.suffix.lower() == '.mp3':
                        audio.export(
                            str(compressed_path),
                            format="mp3",
                            bitrate="64k",
                            parameters=["-q:a", "5"]  # 품질 설정
                        )
                    elif compressed_path.suffix.lower() in ['.aac', '.m4a']:
                        audio.export(
                            str(compressed_path),
                            format="aac",
                            bitrate="64k"
                        )
                    else:
                        # 기본적으로 MP3로 저장
                        compressed_path = compressed_path.with_suffix('.mp3')
                        audio.export(
                            str(compressed_path),
                            format="mp3",
                            bitrate="64k"
                        )
                    
                    return compressed_path
                    
                except Exception as sync_error:
                    print(f"동기 압축 처리 실패: {sync_error}")
                    raise sync_error
            
            # 별도 스레드에서 CPU 집약적 작업 수행
            loop = asyncio.get_event_loop()
            result_path = await loop.run_in_executor(None, _compress_sync)
            
            # 압축 결과 확인
            if result_path.exists():
                original_size = file_path.stat().st_size
                compressed_size = result_path.stat().st_size
                compression_ratio = (1 - compressed_size / original_size) * 100
                
                print(f"✅ 압축 완료: {original_size:,} bytes -> {compressed_size:,} bytes ({compression_ratio:.1f}% 절약)")
                
                # 압축이 효과적이지 않다면 원본 반환
                if compressed_size >= original_size * 0.9:  # 10% 미만 절약시
                    print("⚠️ 압축 효과 미미, 원본 파일 사용")
                    if result_path.exists():
                        result_path.unlink()  # 압축 파일 삭제
                    return file_path
                
                return result_path
            else:
                print("❌ 압축 파일이 생성되지 않음")
                return file_path
                
        except ImportError:
            print("❌ pydub이 설치되지 않음 - 원본 파일 사용")
            return file_path
        except Exception as e:
            print(f"❌ 오디오 압축 실패: {e}")
            return file_path
    
    async def cleanup_temp_files(self, max_age_hours: int = 24):
        """오래된 임시 파일 정리"""
        import time
        current_time = time.time()
        max_age_seconds = max_age_hours * 3600
        
        for file_path in self.temp_dir.glob("temp_*"):
            if file_path.is_file():
                file_age = current_time - file_path.stat().st_mtime
                if file_age > max_age_seconds:
                    try:
                        file_path.unlink()
                        print(f"임시 파일 삭제: {file_path}")
                    except Exception as e:
                        print(f"임시 파일 삭제 실패 {file_path}: {e}")


# 서비스 인스턴스
audio_processing_service = AudioProcessingService()