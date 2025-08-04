import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  @override
  void initState() {
    super.initState();
  }

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
                    children: [
                      _buildAppIcon(),
                      const SizedBox(height: 40),
                      _buildAppInfo(),
                      const SizedBox(height: 40),
                      _buildDeveloperInfo(),
                      const SizedBox(height: 40),
                      _buildLegalInfo(),
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
            '앱 정보',
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

  Widget _buildAppIcon() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_menu,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppConfig.appName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '가족의 요리 레시피를 음성으로 기록하는 앱',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAppInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '앱 정보',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('버전', AppConfig.appVersion),
          _buildInfoRow('빌드 번호', '1'),
          _buildInfoRow('패키지명', 'com.momento.app'),
          _buildInfoRow('앱 이름', AppConfig.appName),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '개발자 정보',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('개발팀', 'MOMENTO Team'),
          _buildInfoRow('연락처', 'support@momento.app'),
          _buildInfoRow('개발 도구', 'Flutter & FastAPI'),
          _buildInfoRow('AI 기술', 'OpenAI GPT & Whisper'),
        ],
      ),
    );
  }

  Widget _buildLegalInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '법적 정보',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionRow(
            '서비스 이용약관',
            Icons.description,
            () => _showTermsOfService(),
          ),
          _buildActionRow(
            '개인정보 처리방침',
            Icons.privacy_tip,
            () => _showPrivacyPolicy(),
          ),
          _buildActionRow(
            '오픈소스 라이선스',
            Icons.code,
            () => _showOpenSourceLicenses(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsOfService() {
    _showLegalDialog(
      '서비스 이용약관',
      '''
MOMENTO 서비스 이용약관

제1조 (목적)
본 약관은 MOMENTO(이하 "회사")가 제공하는 서비스의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (서비스의 내용)
회사는 음성 녹음을 통한 레시피 생성 및 관리 서비스를 제공합니다.

제3조 (개인정보보호)
회사는 관련 법령에 따라 이용자의 개인정보를 보호합니다.

제4조 (서비스 이용)
이용자는 본 약관을 준수하여 서비스를 이용해야 합니다.

제5조 (면책사항)
회사는 천재지변, 전쟁, 기타 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 책임이 면제됩니다.

본 약관은 2025년 1월 1일부터 시행됩니다.
      ''',
    );
  }

  void _showPrivacyPolicy() {
    _showLegalDialog(
      '개인정보 처리방침',
      '''
MOMENTO 개인정보 처리방침

1. 개인정보의 처리 목적
- 서비스 제공 및 이용자 식별
- 음성 녹음 파일 처리 및 레시피 생성
- 서비스 개선 및 고객 지원

2. 수집하는 개인정보 항목
- 필수: 이메일, 이름, 음성 녹음 파일
- 선택: 프로필 이미지

3. 개인정보의 처리 및 보유기간
- 회원탈퇴 시까지 보유
- 관련 법령에 따른 보존 의무가 있는 경우 해당 기간까지 보유

4. 개인정보의 제3자 제공
- 원칙적으로 제3자에게 제공하지 않음
- 법령에 의한 경우 예외

5. 개인정보처리의 위탁
- OpenAI API를 통한 음성 처리 (암호화 전송)

6. 정보주체의 권리
- 개인정보 열람, 정정, 삭제, 처리정지 요구 권리

문의: support@momento.app

본 방침은 2025년 1월 1일부터 시행됩니다.
      ''',
    );
  }

  void _showOpenSourceLicenses() {
    _showLegalDialog(
      '오픈소스 라이선스',
      '''
MOMENTO에서 사용된 오픈소스 라이브러리

Flutter Framework
- Copyright (c) 2017, Google Inc.
- BSD 3-Clause License

Dio HTTP Client
- Copyright (c) 2014, the Dio authors
- MIT License

Provider State Management
- Copyright (c) 2019, Remi Rousselet
- MIT License

Image Picker & Cropper
- Copyright (c) 2019, the Flutter team
- Apache License 2.0

FastAPI
- Copyright (c) 2018, Sebastián Ramírez
- MIT License

SQLAlchemy
- Copyright (c) 2006-2023, the SQLAlchemy authors
- MIT License

기타 자세한 라이선스 정보는 각 라이브러리의 공식 문서를 참조하시기 바랍니다.

모든 오픈소스 프로젝트에 감사드립니다.
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