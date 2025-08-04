import 'package:flutter/foundation.dart';
import '../models/inquiry.dart';
import '../services/api/inquiry_service.dart';
import '../services/api/api_service.dart';

class InquiryProvider with ChangeNotifier {
  final InquiryService _inquiryService = InquiryService(ApiService().dio);

  // 문의사항 목록
  List<InquiryListItem> _inquiries = [];
  List<InquiryListItem> get inquiries => _inquiries;

  // 문의사항 상세
  Inquiry? _currentInquiry;
  Inquiry? get currentInquiry => _currentInquiry;

  // 통계
  InquiryStats? _stats;
  InquiryStats? get stats => _stats;

  // 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  // 에러 상태
  String? _error;
  String? get error => _error;

  // 필터 상태
  InquiryStatus? _statusFilter;
  InquiryStatus? get statusFilter => _statusFilter;

  InquiryCategory? _categoryFilter;
  InquiryCategory? get categoryFilter => _categoryFilter;

  // 페이지네이션
  int _currentPage = 0;
  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  /// 에러 클리어
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 문의사항 목록 조회
  Future<void> loadInquiries({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;

      if (refresh) {
        _currentPage = 0;
        _hasMoreData = true;
      }

      notifyListeners();

      final inquiries = await _inquiryService.getInquiries(
        status: _statusFilter?.name,
        category: _categoryFilter?.name,
        skip: refresh ? 0 : _currentPage * 20,
        limit: 20,
      );

      if (refresh) {
        _inquiries = inquiries;
      } else {
        _inquiries.addAll(inquiries);
      }

      // 더 가져올 데이터가 있는지 확인
      _hasMoreData = inquiries.length == 20;
      if (!refresh) {
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
      print('❌ InquiryProvider.loadInquiries error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 더 많은 문의사항 로드
  Future<void> loadMoreInquiries() async {
    if (!_hasMoreData || _isLoading) return;
    await loadInquiries(refresh: false);
  }

  /// 문의사항 통계 조회
  Future<void> loadStats() async {
    try {
      _stats = await _inquiryService.getInquiryStats();
      notifyListeners();
    } catch (e) {
      print('❌ InquiryProvider.loadStats error: $e');
      // 통계는 실패해도 크리티컬하지 않으므로 에러 상태에 반영하지 않음
    }
  }

  /// 문의사항 상세 조회
  Future<void> loadInquiry(String inquiryId) async {
    if (_isLoadingDetail) return;

    try {
      _isLoadingDetail = true;
      _error = null;
      notifyListeners();

      _currentInquiry = await _inquiryService.getInquiry(inquiryId);
    } catch (e) {
      _error = e.toString();
      print('❌ InquiryProvider.loadInquiry error: $e');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// 문의사항 작성
  Future<bool> createInquiry(InquiryCreateRequest request) async {
    try {
      _error = null;

      final inquiry = await _inquiryService.createInquiry(request);

      // 목록에 새로운 문의사항 추가 (맨 앞에)
      final newItem = InquiryListItem(
        id: inquiry.id,
        title: inquiry.title,
        category: inquiry.category,
        status: inquiry.status,
        createdAt: inquiry.createdAt,
        updatedAt: inquiry.updatedAt,
        hasResponse: inquiry.hasResponse,
      );

      _inquiries.insert(0, newItem);

      // 통계 업데이트
      if (_stats != null) {
        _stats = InquiryStats(
          total: _stats!.total + 1,
          pending: _stats!.pending + 1,
          answered: _stats!.answered,
          closed: _stats!.closed,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ InquiryProvider.createInquiry error: $e');
      notifyListeners();
      return false;
    }
  }

  /// 문의사항 수정
  Future<bool> updateInquiry(
      String inquiryId, InquiryUpdateRequest request) async {
    try {
      _error = null;

      final updatedInquiry =
          await _inquiryService.updateInquiry(inquiryId, request);

      // 목록에서 해당 항목 업데이트
      final index = _inquiries.indexWhere((item) => item.id == inquiryId);
      if (index != -1) {
        _inquiries[index] = InquiryListItem(
          id: updatedInquiry.id,
          title: updatedInquiry.title,
          category: updatedInquiry.category,
          status: updatedInquiry.status,
          createdAt: updatedInquiry.createdAt,
          updatedAt: updatedInquiry.updatedAt,
          hasResponse: updatedInquiry.hasResponse,
        );
      }

      // 현재 상세 항목이 업데이트된 것과 같다면 업데이트
      if (_currentInquiry?.id == inquiryId) {
        _currentInquiry = updatedInquiry;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ InquiryProvider.updateInquiry error: $e');
      notifyListeners();
      return false;
    }
  }

  /// 문의사항 삭제
  Future<bool> deleteInquiry(String inquiryId) async {
    try {
      _error = null;

      await _inquiryService.deleteInquiry(inquiryId);

      // 목록에서 해당 항목 제거
      _inquiries.removeWhere((item) => item.id == inquiryId);

      // 현재 상세 항목이 삭제된 것과 같다면 클리어
      if (_currentInquiry?.id == inquiryId) {
        _currentInquiry = null;
      }

      // 통계 업데이트
      if (_stats != null) {
        _stats = InquiryStats(
          total: _stats!.total - 1,
          pending: _stats!.pending - 1,
          answered: _stats!.answered,
          closed: _stats!.closed,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ InquiryProvider.deleteInquiry error: $e');
      notifyListeners();
      return false;
    }
  }

  /// 필터 설정
  void setStatusFilter(InquiryStatus? status) {
    if (_statusFilter != status) {
      _statusFilter = status;
      loadInquiries(refresh: true);
    }
  }

  void setCategoryFilter(InquiryCategory? category) {
    if (_categoryFilter != category) {
      _categoryFilter = category;
      loadInquiries(refresh: true);
    }
  }

  /// 필터 초기화
  void clearFilters() {
    bool shouldRefresh = _statusFilter != null || _categoryFilter != null;
    _statusFilter = null;
    _categoryFilter = null;

    if (shouldRefresh) {
      loadInquiries(refresh: true);
    }
  }

  /// 상세 데이터 클리어
  void clearCurrentInquiry() {
    _currentInquiry = null;
    notifyListeners();
  }

  /// 전체 데이터 초기화
  void clear() {
    _inquiries.clear();
    _currentInquiry = null;
    _stats = null;
    _error = null;
    _statusFilter = null;
    _categoryFilter = null;
    _currentPage = 0;
    _hasMoreData = true;
    notifyListeners();
  }
}
