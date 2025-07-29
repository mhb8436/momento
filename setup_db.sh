#!/bin/bash

# MOMENTO PostgreSQL 데이터베이스 설정 스크립트

echo "🐘 MOMENTO PostgreSQL 데이터베이스를 설정합니다..."

# PostgreSQL이 실행 중인지 확인
if ! pgrep -x "postgres" >/dev/null; then
    echo "❌ PostgreSQL이 실행되지 않고 있습니다."
    echo "다음 명령어로 PostgreSQL을 시작해주세요:"
    echo "brew services start postgresql"
    exit 1
fi

echo "📊 데이터베이스와 사용자를 생성합니다..."

# SQL 명령어를 파일로 생성
cat > /tmp/momento_setup.sql << EOF
-- Check if user exists before creating
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'momento_user') THEN
        CREATE USER momento_user WITH PASSWORD 'momento_password';
        RAISE NOTICE 'User momento_user created';
    ELSE
        RAISE NOTICE 'User momento_user already exists';
    END IF;
END
\$\$;

-- Check if database exists before creating
SELECT 'CREATE DATABASE momento'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'momento')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE momento TO momento_user;
ALTER DATABASE momento OWNER TO momento_user;

-- Display results
\echo '✅ 데이터베이스 설정 완료!'
\echo '📋 설정 정보:'
SELECT 
    d.datname as "데이터베이스",
    pg_catalog.pg_get_userbyid(d.datdba) as "소유자"
FROM pg_catalog.pg_database d
WHERE d.datname = 'momento';

\echo '👤 사용자 정보:'
SELECT usename as "사용자명", usecreatedb as "DB생성권한", usesuper as "슈퍼유저"
FROM pg_user 
WHERE usename = 'momento_user';
EOF

# SQL 스크립트 실행
psql postgres -f /tmp/momento_setup.sql

# 임시 파일 삭제
rm /tmp/momento_setup.sql

echo ""
echo "🎉 데이터베이스 설정이 완료되었습니다!"
echo ""
echo "📝 연결 정보:"
echo "  호스트: localhost"
echo "  포트: 5432"
echo "  데이터베이스: momento"
echo "  사용자: momento_user"
echo "  비밀번호: momento_password"
echo ""
echo "🔗 연결 테스트:"
echo "  psql -U momento_user -d momento -h localhost"
echo ""
echo "🚀 이제 서버를 시작할 수 있습니다:"
echo "  ./start_server.sh"