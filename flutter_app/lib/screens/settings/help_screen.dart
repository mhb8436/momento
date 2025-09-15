import 'package:flutter/material.dart';
import '../../config/theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<HelpItem> _helpItems = [
    HelpItem(
      category: '시작하기',
      items: [
        HelpSubItem(
          question: '어떻게 첫 레시피를 만들 수 있나요?',
          answer: '''
1. 하단 탭의 '+' 버튼을 눌러주세요
2. '음성 녹음' 메뉴를 선택하세요
3. 녹음 버튼을 눌러 요리법을 말씀해 주세요
4. 완료 버튼을 누르면 AI가 자동으로 레시피를 정리해 드립니다

💡 팁: 재료, 조리법, 팁을 포함해서 자세히 말씀해 주시면 더 정확한 레시피가 생성됩니다.
          ''',
        ),
        HelpSubItem(
          question: '계정은 어떻게 만드나요?',
          answer: '''
1. 앱을 처음 실행하면 로그인 화면이 나타납니다
2. '회원가입' 버튼을 눌러주세요
3. 이메일과 비밀번호, 이름을 입력하세요
4. 가입 완료 후 바로 서비스를 이용할 수 있습니다

📧 이메일은 계정 복구 및 중요한 알림을 위해 사용됩니다.
          ''',
        ),
      ],
    ),
    HelpItem(
      category: '음성 녹음',
      items: [
        HelpSubItem(
          question: '음성 녹음이 잘 안되요',
          answer: '''
다음 사항을 확인해 주세요:

1. 마이크 권한 확인
   - 설정 > 개인정보 보호 > 마이크에서 MOMENTO 앱 권한을 확인하세요

2. 조용한 환경에서 녹음
   - 주변 소음이 적은 곳에서 녹음해 주세요
   - 마이크에 가까이 말씀해 주세요

3. 명확한 발음
   - 천천히, 명확하게 말씀해 주세요
   - 전문 용어보다는 일반적인 표현을 사용해 주세요

🎤 녹음 품질이 좋을수록 더 정확한 레시피가 생성됩니다.
          ''',
        ),
        HelpSubItem(
          question: '녹음할 때 어떻게 말해야 하나요?',
          answer: '''
효과적인 녹음 방법:

1. 재료부터 시작
   "오늘은 김치찌개를 만들어볼게요. 재료는 김치 200g, 돼지고기 150g..."

2. 순서대로 설명
   "먼저 돼지고기를 볶고, 그 다음에 김치를 넣어서..."

3. 중요한 팁 추가
   "김치는 잘 익은 것으로 사용하면 더 맛있어요"

4. 시간과 온도 명시
   "중불에서 10분간 끓여주세요"

📝 실제로 요리하는 것처럼 자연스럽게 말씀해 주시면 됩니다.
          ''',
        ),
      ],
    ),
    HelpItem(
      category: '레시피 관리',
      items: [
        HelpSubItem(
          question: '레시피를 수정할 수 있나요?',
          answer: '''
네, 생성된 레시피는 언제든지 수정할 수 있습니다:

1. 레시피 목록에서 수정하고 싶은 레시피를 선택하세요
2. 우측 상단의 편집 버튼을 눌러주세요
3. 제목, 재료, 조리법을 자유롭게 수정하세요
4. 저장 버튼을 눌러 변경사항을 저장하세요

✏️ AI가 생성한 내용을 바탕으로 더 자세하게 보완하실 수 있습니다.
          ''',
        ),
        HelpSubItem(
          question: '레시피를 삭제하려면?',
          answer: '''
레시피 삭제 방법:

1. 레시피 목록에서 삭제할 레시피를 선택하세요
2. 우측 상단의 더보기 메뉴(⋯)를 눌러주세요
3. '삭제' 옵션을 선택하세요
4. 확인 메시지에서 '삭제'를 다시 한 번 눌러주세요

⚠️ 삭제된 레시피는 복구할 수 없으니 신중하게 결정해 주세요.
          ''',
        ),
        HelpSubItem(
          question: '레시피에 사진을 추가할 수 있나요?',
          answer: '''
네, 레시피에 사진을 추가할 수 있습니다:

1. 레시피 생성 또는 편집 화면에서
2. 이미지 추가 버튼(카메라 아이콘)을 눌러주세요
3. 카메라로 촬영하거나 갤러리에서 선택하세요
4. 필요시 사진을 크롭하여 조정하세요

📸 완성된 요리 사진을 추가하면 레시피가 더욱 생생해집니다.
          ''',
        ),
      ],
    ),
    HelpItem(
      category: '프로필 & 설정',
      items: [
        HelpSubItem(
          question: '프로필 사진을 변경하려면?',
          answer: '''
프로필 사진 변경 방법:

1. 하단 탭의 '프로필' 메뉴로 이동하세요
2. 프로필 헤더에서 '사진 변경' 버튼을 눌러주세요
3. 카메라로 촬영하거나 갤러리에서 선택하세요
4. 사진을 크롭하여 원하는 부분만 선택하세요
5. '저장하기' 버튼을 눌러 완료하세요

👤 프로필 사진은 언제든지 변경할 수 있습니다.
          ''',
        ),
        HelpSubItem(
          question: '비밀번호를 잊어버렸어요',
          answer: '''
비밀번호 재설정 방법:

1. 로그인 화면에서 '비밀번호 찾기'를 눌러주세요
2. 가입할 때 사용한 이메일을 입력하세요
3. 이메일로 전송된 재설정 링크를 클릭하세요
4. 새로운 비밀번호를 설정하세요

🔐 보안을 위해 강력한 비밀번호를 사용하시기 바랍니다.
          ''',
        ),
      ],
    ),
    HelpItem(
      category: '문제 해결',
      items: [
        HelpSubItem(
          question: '앱이 계속 종료돼요',
          answer: '''
앱 종료 문제 해결 방법:

1. 앱 완전 종료 후 재시작
   - 앱 전환기에서 MOMENTO를 위로 밀어 종료
   - 다시 앱을 실행해 보세요

2. 기기 재시작
   - 기기를 완전히 재시작해 보세요

3. 앱 업데이트 확인
   - 앱스토어에서 최신 버전으로 업데이트하세요

4. 저장 공간 확인
   - 기기의 저장 공간이 부족한지 확인하세요

여전히 문제가 지속되면 피드백을 보내주세요.
          ''',
        ),
        HelpSubItem(
          question: '레시피 생성이 오래 걸려요',
          answer: '''
레시피 생성 시간을 단축하는 방법:

1. 안정적인 인터넷 연결 확인
   - Wi-Fi 또는 4G/5G 연결 상태를 확인하세요

2. 녹음 시간 조절
   - 너무 긴 녹음보다는 3-5분 정도가 적당합니다

3. 명확한 발음
   - 명확하게 말씀하시면 AI 처리 시간이 단축됩니다

⏱️ 일반적으로 1-2분 정도 소요되며, 음성 길이에 따라 차이가 있을 수 있습니다.
          ''',
        ),
        HelpSubItem(
          question: '생성된 레시피가 이상해요',
          answer: '''
레시피 품질을 개선하는 방법:

1. 더 자세한 설명
   - 재료의 양, 조리 시간, 온도 등을 구체적으로 말씀해 주세요

2. 단계별 설명
   - "먼저", "그 다음", "마지막으로" 등의 순서 표현을 사용하세요

3. 방언보다는 표준어
   - 가능한 표준어로 말씀해 주시기 바랍니다

4. 수동 편집
   - 생성된 레시피를 직접 편집하여 완성도를 높이세요

🤖 AI는 계속 학습하고 있어서 점점 더 정확해집니다.
          ''',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              Expanded(
                child: _buildHelpContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            '도움말',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: '궁금한 내용을 검색해보세요',
            prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintStyle: TextStyle(color: AppTheme.textLight),
          ),
          onChanged: (value) {
            // TODO: Implement search functionality
          },
        ),
      ),
    );
  }

  Widget _buildHelpContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildQuickActions(),
          const SizedBox(height: 32),
          ..._helpItems.map((category) => _buildHelpCategory(category)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '빠른 도움말',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildQuickActionButton(
          //         icon: Icons.video_library,
          //         title: '사용법 영상',
          //         onTap: () => _showVideoTutorial(),
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: _buildQuickActionButton(
          //         icon: Icons.chat_bubble_outline,
          //         title: '실시간 채팅',
          //         onTap: () => _startLiveChat(),
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.email_outlined,
                  title: '이메일 문의',
                  onTap: () => _sendEmail(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCategory(HelpItem category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          category.category,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getCategoryIcon(category.category),
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        children: category.items.map((item) => _buildHelpItem(item)).toList(),
      ),
    );
  }

  Widget _buildHelpItem(HelpSubItem item) {
    return ExpansionTile(
      title: Text(
        item.question,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            item.answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '시작하기':
        return Icons.play_circle_outline;
      case '음성 녹음':
        return Icons.mic_none;
      case '레시피 관리':
        return Icons.restaurant_menu;
      case '프로필 & 설정':
        return Icons.person_outline;
      case '문제 해결':
        return Icons.build_outlined;
      default:
        return Icons.help_outline;
    }
  }

  void _showVideoTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용법 영상'),
        content: const Text(
          'MOMENTO 사용법을 쉽게 배울 수 있는 영상 튜토리얼을 준비 중입니다.\n\n'
          '곧 업데이트를 통해 제공될 예정입니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }


  void _sendEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('이메일 앱으로 연결됩니다: support@momento.app'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

}

class HelpItem {
  final String category;
  final List<HelpSubItem> items;

  HelpItem({
    required this.category,
    required this.items,
  });
}

class HelpSubItem {
  final String question;
  final String answer;

  HelpSubItem({
    required this.question,
    required this.answer,
  });
}