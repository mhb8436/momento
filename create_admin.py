#!/usr/bin/env python3
"""
기본 관리자 계정을 생성하는 스크립트

사용법:
python create_admin.py --email admin@momento.app --password yourpassword
"""

import asyncio
import argparse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import async_engine
from app.models.user import User, UserRole
from app.utils.security import get_password_hash


async def create_admin_user(email: str, password: str, full_name: str = "System Admin"):
    """관리자 계정 생성"""
    async with AsyncSession(async_engine) as session:
        try:
            # 이미 존재하는 계정인지 확인
            result = await session.execute(
                select(User).where(User.email == email)
            )
            existing_user = result.scalar_one_or_none()
            
            if existing_user:
                print(f"❌ 이미 존재하는 이메일입니다: {email}")
                
                # 기존 사용자를 관리자로 승격
                if not existing_user.is_admin:
                    existing_user.role = UserRole.ADMIN
                    existing_user.is_admin = True
                    await session.commit()
                    print(f"✅ 기존 사용자를 관리자로 승격했습니다: {email}")
                else:
                    print(f"ℹ️  이미 관리자 계정입니다: {email}")
                return
            
            # 새 관리자 계정 생성
            hashed_password = get_password_hash(password)
            admin_user = User(
                email=email,
                password_hash=hashed_password,
                full_name=full_name,
                role=UserRole.ADMIN,
                is_admin=True,
                is_active=True
            )
            
            session.add(admin_user)
            await session.commit()
            await session.refresh(admin_user)
            
            print(f"✅ 관리자 계정이 생성되었습니다:")
            print(f"   이메일: {admin_user.email}")
            print(f"   이름: {admin_user.full_name}")
            print(f"   역할: {admin_user.role.value}")
            print(f"   ID: {admin_user.id}")
            
        except Exception as e:
            print(f"❌ 관리자 계정 생성 실패: {e}")
            await session.rollback()


async def list_admins():
    """현재 관리자 계정 목록 조회"""
    async with AsyncSession(async_engine) as session:
        try:
            result = await session.execute(
                select(User).where(User.is_admin == True)
            )
            admins = result.scalars().all()
            
            if not admins:
                print("📝 관리자 계정이 없습니다.")
                return
            
            print(f"📝 현재 관리자 계정 ({len(admins)}개):")
            for admin in admins:
                print(f"   • {admin.email} ({admin.full_name}) - {admin.role.value}")
                
        except Exception as e:
            print(f"❌ 관리자 목록 조회 실패: {e}")


def main():
    parser = argparse.ArgumentParser(description="MOMENTO 관리자 계정 관리")
    parser.add_argument("--email", help="관리자 이메일 주소")
    parser.add_argument("--password", help="관리자 비밀번호")
    parser.add_argument("--name", default="System Admin", help="관리자 이름")
    parser.add_argument("--list", action="store_true", help="현재 관리자 목록 조회")
    
    args = parser.parse_args()
    
    if args.list:
        print("🔍 관리자 계정 목록 조회 중...")
        asyncio.run(list_admins())
        return
    
    if not args.email or not args.password:
        print("❌ 이메일과 비밀번호를 모두 입력해주세요.")
        print("예시: python create_admin.py --email admin@momento.app --password yourpassword")
        return
    
    if len(args.password) < 8:
        print("❌ 비밀번호는 최소 8자 이상이어야 합니다.")
        return
    
    print(f"👤 관리자 계정 생성 중...")
    print(f"   이메일: {args.email}")
    print(f"   이름: {args.name}")
    
    asyncio.run(create_admin_user(args.email, args.password, args.name))


if __name__ == "__main__":
    main()