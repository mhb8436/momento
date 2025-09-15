import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'password_change_screen.dart';
import 'account_deletion_screen.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _dataAnalyticsEnabled = true;
  bool _personalizedAdsEnabled = false;
  bool _crashReportingEnabled = true;
  bool _locationDataEnabled = false;

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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // _buildPrivacySection(),
                      // const SizedBox(height: 32),
                      _buildDataSection(),
                      const SizedBox(height: 32),
                      _buildAccountSection(),
                      const SizedBox(height: 32),
                      _buildLegalSection(),
                    ],
                  ),
                ),
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
            '개인정보 보호',
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

  Widget _buildPrivacySection() {
    return _buildSection(
      title: '개인정보 설정',
      children: [
        _buildSwitchTile(
          title: '데이터 분석 허용',
          subtitle: '앱 사용 패턴 분석을 통한 서비스 개선',
          value: _dataAnalyticsEnabled,
          onChanged: (value) {
            setState(() {
              _dataAnalyticsEnabled = value;
            });
          },
        ),
        _buildSwitchTile(
          title: '맞춤형 광고',
          subtitle: '사용자 관심사 기반 광고 표시',
          value: _personalizedAdsEnabled,
          onChanged: (value) {
            setState(() {
              _personalizedAdsEnabled = value;
            });
          },
        ),
        _buildSwitchTile(
          title: '오류 보고',
          subtitle: '앱 오류 및 충돌 정보 자동 전송',
          value: _crashReportingEnabled,
          onChanged: (value) {
            setState(() {
              _crashReportingEnabled = value;
            });
          },
        ),
        _buildSwitchTile(
          title: '위치 정보 사용',
          subtitle: '지역별 맞춤 레시피 추천 (현재 미사용)',
          value: _locationDataEnabled,
          onChanged: (value) {
            setState(() {
              _locationDataEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      title: '데이터 관리',
      children: [
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: '계정 관리',
      children: [
        _buildActionTile(
          icon: Icons.lock_reset,
          title: '비밀번호 변경',
          subtitle: '계정 보안을 위해 정기적으로 변경하세요',
          onTap: _changePassword,
        ),
        _buildActionTile(
          icon: Icons.delete_outline,
          title: '계정 삭제',
          subtitle: '계정과 모든 데이터를 영구 삭제',
          onTap: _deleteAccount,
          textColor: AppTheme.errorColor,
          iconColor: AppTheme.errorColor,
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    return _buildSection(
      title: '법적 정보',
      children: [
        _buildActionTile(
          icon: Icons.description,
          title: '개인정보 처리방침',
          subtitle: '개인정보 수집 및 이용에 대한 안내',
          onTap: _showPrivacyPolicy,
        ),
        _buildActionTile(
          icon: Icons.gavel,
          title: '서비스 이용약관',
          subtitle: '서비스 이용에 관한 약관',
          onTap: _showTermsOfService,
        ),
        _buildActionTile(
          icon: Icons.cookie,
          title: '쿠키 정책',
          subtitle: '쿠키 사용에 대한 정책',
          onTap: _showCookiePolicy,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        Container(
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
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (index < children.length - 1) _buildDivider(),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textColor ?? AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: AppTheme.textLight.withOpacity(0.2),
      ),
    );
  }



  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PasswordChangeScreen(),
      ),
    );
  }


  void _deleteAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountDeletionScreen(),
      ),
    );
  }

  void _showPrivacyPolicy() {
    _showLegalDialog(
      '개인정보 처리방침',
      '''
MOMENTO 개인정보 처리방침

1. 개인정보의 처리 목적
MOMENTO('회사')는 다음의 목적을 위하여 개인정보를 처리합니다.

• 서비스 제공 및 회원 관리
• 음성 녹음 파일 처리 및 레시피 생성
• 맞춤형 서비스 제공
• 서비스 개선 및 신규 서비스 개발
• 고객 문의 및 불만 처리

2. 수집하는 개인정보 항목
• 필수정보: 이메일, 이름, 음성 녹음 파일
• 선택정보: 프로필 이미지, 위치 정보
• 자동 수집: 서비스 이용 기록, 접속 로그, 기기 정보

3. 개인정보의 처리 및 보유기간
• 회원탈퇴 시까지: 회원 정보, 서비스 이용 기록
• 법정 보존기간: 관련 법령에 따른 의무 보존 정보

4. 개인정보 제3자 제공
회사는 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다.
단, 다음의 경우는 예외로 합니다:
• 이용자가 사전에 동의한 경우
• 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우

5. 개인정보 처리 위탁
회사는 서비스 향상을 위해 아래와 같이 개인정보 처리업무를 위탁하고 있습니다:
• OpenAI: 음성 파일 텍스트 변환 (미국)
• AWS: 클라우드 인프라 서비스

6. 정보주체의 권리·의무 및 행사방법
이용자는 개인정보 주체로서 다음과 같은 권리를 행사할 수 있습니다:
• 개인정보 열람·처리정지·삭제요구 권리
• 개인정보 정정·삭제요구 권리
• 손해배상청구 권리

7. 개인정보 보호책임자
이름: MOMENTO 개인정보보호팀
연락처: privacy@momento.app

본 방침은 2025년 1월 1일부터 시행됩니다.
      ''',
    );
  }

  void _showTermsOfService() {
    _showLegalDialog(
      '서비스 이용약관',
      '''
MOMENTO 서비스 이용약관

제1조 (목적)
본 약관은 MOMENTO(이하 "회사")가 제공하는 음성 녹음 기반 레시피 관리 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "서비스"란 회사가 제공하는 모든 서비스를 의미합니다.
2. "이용자"란 본 약관에 따라 회사와 서비스 이용계약을 체결하고 회사가 제공하는 서비스를 이용하는 고객을 말합니다.

제3조 (서비스의 내용)
회사는 다음과 같은 서비스를 제공합니다:
1. 음성 녹음을 통한 레시피 생성 서비스
2. 레시피 관리 및 공유 서비스
3. 기타 회사가 정하는 서비스

제4조 (서비스 이용계약의 성립)
1. 서비스 이용계약은 이용신청자가 본 약관에 동의하고 회사가 그 신청에 대해 승낙함으로써 성립됩니다.
2. 회사는 다음 각 호에 해당하는 신청에 대하여는 승낙을 하지 않을 수 있습니다:
   • 실명이 아니거나 타인의 명의를 이용한 경우
   • 허위의 정보를 기재하거나, 회사가 제시하는 내용을 기재하지 않은 경우

제5조 (개인정보보호)
회사는 관련 법령이 정하는 바에 따라 이용자의 개인정보를 보호하기 위해 노력합니다.

제6조 (서비스 이용료)
현재 제공되는 기본 서비스는 무료입니다.

제7조 (서비스 이용 제한)
회사는 이용자가 다음 각 호에 해당하는 행위를 하는 경우 사전 통지 없이 서비스 이용을 제한할 수 있습니다:
1. 다른 이용자의 개인정보를 도용하는 행위
2. 서비스 운영을 고의로 방해하는 행위
3. 공공질서 및 미풍양속에 저해되는 내용을 유포하는 행위

제8조 (면책사항)
1. 회사는 천재지변, 전쟁 기타 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 책임이 면제됩니다.
2. 회사는 이용자의 귀책사유로 인한 서비스 이용의 장애에 대하여는 책임을 지지 않습니다.

제9조 (준거법 및 관할)
본 약관의 해석 및 회사와 이용자 간의 분쟁에 대하여는 대한민국의 법을 적용하며, 서울중앙지방법원을 관할 법원으로 합니다.

본 약관은 2025년 1월 1일부터 시행됩니다.
      ''',
    );
  }

  void _showCookiePolicy() {
    _showLegalDialog(
      '쿠키 정책',
      '''
MOMENTO 쿠키 정책

1. 쿠키란?
쿠키(Cookie)는 웹사이트를 방문할 때 브라우저에 저장되는 작은 텍스트 파일입니다. 쿠키를 통해 웹사이트는 사용자의 방문을 기억하고 다음 방문 시 더 나은 경험을 제공할 수 있습니다.

2. 쿠키 사용 목적
MOMENTO는 다음과 같은 목적으로 쿠키를 사용합니다:
• 로그인 상태 유지
• 사용자 설정 및 선호도 저장
• 서비스 이용 통계 분석
• 보안 강화

3. 사용하는 쿠키 유형
• 필수 쿠키: 서비스 제공에 반드시 필요한 쿠키
• 기능 쿠키: 사용자 경험 향상을 위한 쿠키
• 분석 쿠키: 서비스 이용 패턴 분석을 위한 쿠키
• 광고 쿠키: 맞춤형 광고 제공을 위한 쿠키 (현재 미사용)

4. 쿠키 관리
사용자는 브라우저 설정을 통해 쿠키를 관리할 수 있습니다:
• 모든 쿠키 허용
• 쿠키 허용 시 알림
• 모든 쿠키 차단

단, 필수 쿠키를 차단할 경우 일부 서비스 이용에 제한이 있을 수 있습니다.

5. 제3자 쿠키
MOMENTO는 서비스 개선을 위해 다음과 같은 제3자 서비스를 이용할 수 있습니다:
• Google Analytics (현재 미사용)
• 기타 분석 도구

6. 연락처
쿠키 정책에 대한 문의사항은 다음으로 연락해 주시기 바랍니다:
이메일: privacy@momento.app

본 정책은 2025년 1월 1일부터 시행됩니다.
      ''',
    );
  }

  void _showLegalDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.6,
                    color: AppTheme.textPrimary,
                  ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '확인',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
