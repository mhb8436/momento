"""
기존 문의사항 카테고리를 3개로 단순화하는 마이그레이션 스크립트
"""

category_mapping = {
    # 기존 카테고리 -> 새 카테고리
    'general': 'general',      # 일반 문의 -> 일반 문의
    'account': 'general',      # 계정 문의 -> 일반 문의
    
    'bug': 'problem',          # 버그 신고 -> 문제 신고
    'ui': 'problem',           # UI/UX 관련 -> 문제 신고  
    'performance': 'problem',  # 성능 관련 -> 문제 신고
    'audio': 'problem',        # 음성 관련 -> 문제 신고
    'recipe': 'problem',       # 레시피 관련 -> 문제 신고 (대부분 문제일 가능성)
    
    'feature': 'suggestion',   # 기능 제안 -> 개선 제안
}

# SQL 업데이트 명령어들
sql_commands = []

for old_category, new_category in category_mapping.items():
    if old_category != new_category:
        sql_commands.append(
            f"UPDATE inquiries SET category = '{new_category}' WHERE category = '{old_category}';"
        )

print("=== 문의사항 카테고리 마이그레이션 SQL ===")
print()
for cmd in sql_commands:
    print(cmd)

print()
print("=== 마이그레이션 통계 예상 ===")
print("• 일반 문의: general, account → general")  
print("• 문제 신고: bug, ui, performance, audio, recipe → problem")
print("• 개선 제안: feature → suggestion")