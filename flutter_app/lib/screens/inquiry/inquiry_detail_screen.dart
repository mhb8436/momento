import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/inquiry.dart';
import '../../providers/inquiry_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import 'inquiry_edit_screen.dart';

class InquiryDetailScreen extends StatefulWidget {
  final String inquiryId;

  const InquiryDetailScreen({
    super.key,
    required this.inquiryId,
  });

  @override
  State<InquiryDetailScreen> createState() => _InquiryDetailScreenState();
}

class _InquiryDetailScreenState extends State<InquiryDetailScreen> {
  @override
  void initState() {
    super.initState();
    
    // 문의사항 상세 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<InquiryProvider>(context, listen: false);
      provider.loadInquiry(widget.inquiryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<InquiryProvider>(
            builder: (context, provider, _) {
              return LoadingOverlay(
                isLoading: provider.isLoadingDetail,
                child: Column(
                  children: [
                    _buildAppBar(provider),
                    Expanded(
                      child: _buildContent(provider),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(InquiryProvider provider) {
    final inquiry = provider.currentInquiry;
    final canEdit = inquiry?.status == InquiryStatus.pending;

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
            '문의사항 상세',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          if (inquiry != null && canEdit)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editInquiry(inquiry);
                    break;
                  case 'delete':
                    _deleteInquiry(inquiry);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('수정'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: AppTheme.errorColor)),
                    ],
                  ),
                ),
              ],
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent(InquiryProvider provider) {
    if (provider.error != null) {
      return _buildErrorWidget(provider);
    }

    final inquiry = provider.currentInquiry;
    if (inquiry == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInquiryHeader(inquiry),
          const SizedBox(height: 24),
          _buildInquiryContent(inquiry),
          if (inquiry.hasResponse) ...[
            const SizedBox(height: 32),
            _buildAdminResponse(inquiry),
          ],
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildInquiryHeader(Inquiry inquiry) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      inquiry.category.displayEmoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      inquiry.category.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(inquiry.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      inquiry.status.displayEmoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      inquiry.status.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(inquiry.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            inquiry.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '작성일: ${_formatDateTime(inquiry.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          if (inquiry.updatedAt != inquiry.createdAt) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.edit,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '수정일: ${_formatDateTime(inquiry.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInquiryContent(Inquiry inquiry) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '문의 내용',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGradient.colors.first.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.textLight.withOpacity(0.2),
              ),
            ),
            child: Text(
              inquiry.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminResponse(Inquiry inquiry) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.support_agent,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '관리자 답변',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (inquiry.adminResponseAt != null)
                    Text(
                      _formatDateTime(inquiry.adminResponseAt!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.2),
              ),
            ),
            child: Text(
              inquiry.adminResponse ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(InquiryProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? '알 수 없는 오류가 발생했습니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textSecondary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('돌아가기'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    provider.clearError();
                    provider.loadInquiry(widget.inquiryId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(InquiryStatus status) {
    switch (status) {
      case InquiryStatus.pending:
        return Colors.orange;
      case InquiryStatus.answered:
        return Colors.green;
      case InquiryStatus.closed:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _editInquiry(Inquiry inquiry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InquiryEditScreen(inquiry: inquiry),
      ),
    ).then((result) {
      if (result == true) {
        // 수정되었으면 상세 정보 다시 로드
        final provider = Provider.of<InquiryProvider>(context, listen: false);
        provider.loadInquiry(widget.inquiryId);
        // 상위 화면에 변경 사항 알림
        Navigator.pop(context, true);
      }
    });
  }

  void _deleteInquiry(Inquiry inquiry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문의사항 삭제'),
        content: const Text(
          '이 문의사항을 삭제하시겠습니까?\n\n'
          '삭제된 문의사항은 복구할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final provider = Provider.of<InquiryProvider>(context, listen: false);
              final success = await provider.deleteInquiry(inquiry.id);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('문의사항이 삭제되었습니다.'),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
                Navigator.pop(context, true);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error ?? '삭제에 실패했습니다.'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}