import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/storage/local_storage_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/common/custom_button.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _inquiryAnswers = true;
  bool _appUpdates = true;
  bool _recipeRecommendations = false;
  bool _systemMaintenance = true;

  // 알림 시간 설정
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);
  bool _enableQuietHours = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _pushNotifications = LocalStorageService.getSetting<bool>('push_notifications', defaultValue: true) ?? true;
      _inquiryAnswers = LocalStorageService.getSetting<bool>('inquiry_answers', defaultValue: true) ?? true;
      _appUpdates = LocalStorageService.getSetting<bool>('app_updates', defaultValue: true) ?? true;
      _recipeRecommendations = LocalStorageService.getSetting<bool>('recipe_recommendations', defaultValue: false) ?? false;
      _systemMaintenance = LocalStorageService.getSetting<bool>('system_maintenance', defaultValue: true) ?? true;
      _enableQuietHours = LocalStorageService.getSetting<bool>('enable_quiet_hours', defaultValue: false) ?? false;
      
      final startHour = LocalStorageService.getSetting<int>('quiet_hours_start_hour', defaultValue: 22) ?? 22;
      final startMinute = LocalStorageService.getSetting<int>('quiet_hours_start_minute', defaultValue: 0) ?? 0;
      final endHour = LocalStorageService.getSetting<int>('quiet_hours_end_hour', defaultValue: 8) ?? 8;
      final endMinute = LocalStorageService.getSetting<int>('quiet_hours_end_minute', defaultValue: 0) ?? 0;
      
      _quietHoursStart = TimeOfDay(hour: startHour, minute: startMinute);
      _quietHoursEnd = TimeOfDay(hour: endHour, minute: endMinute);
    });
  }

  Future<void> _saveSetting<T>(String key, T value) async {
    await LocalStorageService.saveSetting(key, value);
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGeneralNotifications(),
                      const SizedBox(height: 24),
                      _buildSpecificNotifications(),
                      const SizedBox(height: 24),
                      _buildQuietHours(),
                      const SizedBox(height: 24),
                      _buildTestSection(),
                      const SizedBox(height: 24),
                      _buildNotificationInfo(),
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
            '알림 설정',
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

  Widget _buildGeneralNotifications() {
    return _buildSection(
      title: '일반 알림',
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
        child: Column(
          children: [
            _buildSwitchTile(
              title: '푸시 알림',
              subtitle: '모든 푸시 알림을 받습니다',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
                _saveSetting('push_notifications', value);
              },
              icon: Icons.notifications,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificNotifications() {
    return _buildSection(
      title: '세부 알림 설정',
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
        child: Column(
          children: [
            _buildSwitchTile(
              title: '문의 답변 알림',
              subtitle: '문의사항에 대한 답변이 등록되면 알림을 받습니다',
              value: _inquiryAnswers && _pushNotifications,
              onChanged: _pushNotifications ? (value) {
                setState(() {
                  _inquiryAnswers = value;
                });
                _saveSetting('inquiry_answers', value);
              } : null,
              icon: Icons.question_answer,
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: '앱 업데이트 알림',
              subtitle: '새로운 버전이 출시되면 알림을 받습니다',
              value: _appUpdates && _pushNotifications,
              onChanged: _pushNotifications ? (value) {
                setState(() {
                  _appUpdates = value;
                });
                _saveSetting('app_updates', value);
              } : null,
              icon: Icons.system_update,
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: '레시피 추천 알림',
              subtitle: '개인화된 레시피 추천을 받습니다',
              value: _recipeRecommendations && _pushNotifications,
              onChanged: _pushNotifications ? (value) {
                setState(() {
                  _recipeRecommendations = value;
                });
                _saveSetting('recipe_recommendations', value);
              } : null,
              icon: Icons.restaurant_menu,
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: '시스템 점검 알림',
              subtitle: '서비스 점검 및 중요 공지사항을 받습니다',
              value: _systemMaintenance && _pushNotifications,
              onChanged: _pushNotifications ? (value) {
                setState(() {
                  _systemMaintenance = value;
                });
                _saveSetting('system_maintenance', value);
              } : null,
              icon: Icons.settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuietHours() {
    return _buildSection(
      title: '방해 금지 시간',
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
        child: Column(
          children: [
            _buildSwitchTile(
              title: '방해 금지 시간 설정',
              subtitle: '지정된 시간에는 알림을 받지 않습니다',
              value: _enableQuietHours && _pushNotifications,
              onChanged: _pushNotifications ? (value) {
                setState(() {
                  _enableQuietHours = value;
                });
                _saveSetting('enable_quiet_hours', value);
              } : null,
              icon: Icons.bedtime,
            ),
            if (_enableQuietHours && _pushNotifications) ...[
              const Divider(height: 1),
              _buildTimeTile(
                title: '시작 시간',
                time: _quietHoursStart,
                onTap: () => _selectTime(true),
                icon: Icons.nightlight_round,
              ),
              const Divider(height: 1),
              _buildTimeTile(
                title: '종료 시간',
                time: _quietHoursEnd,
                onTap: () => _selectTime(false),
                icon: Icons.wb_sunny,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection() {
    return _buildSection(
      title: '알림 테스트',
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notification_add,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '알림 설정 테스트',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '푸시 알림이 정상적으로 작동하는지 확인하세요',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: '테스트 알림 보내기',
                onPressed: _pushNotifications ? _sendTestNotification : null,
                backgroundColor: AppTheme.primaryColor,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '알림 설정 안내',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• 푸시 알림을 비활성화하면 모든 알림이 차단됩니다\n'
            '• 중요한 보안 알림은 설정과 관계없이 전송될 수 있습니다\n'
            '• 기기 설정에서 알림을 차단한 경우 앱 설정과 관계없이 알림이 표시되지 않습니다\n'
            '• 방해 금지 시간은 로컬 시간을 기준으로 동작합니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
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
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (onChanged != null ? AppTheme.primaryColor : Colors.grey).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: onChanged != null ? AppTheme.primaryColor : Colors.grey,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: onChanged != null ? AppTheme.textPrimary : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time.format(context),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.textLight,
          ),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _quietHoursStart : _quietHoursEnd,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _quietHoursStart = picked;
          _saveSetting('quiet_hours_start_hour', picked.hour);
          _saveSetting('quiet_hours_start_minute', picked.minute);
        } else {
          _quietHoursEnd = picked;
          _saveSetting('quiet_hours_end_hour', picked.hour);
          _saveSetting('quiet_hours_end_minute', picked.minute);
        }
      });
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      await NotificationService.showTestNotification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 테스트 알림이 발송되었습니다!'),
            backgroundColor: AppTheme.primaryColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 알림 발송에 실패했습니다: $e'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}