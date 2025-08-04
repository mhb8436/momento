import 'package:json_annotation/json_annotation.dart';

part 'inquiry.g.dart';

enum InquiryStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('answered')
  answered,
  @JsonValue('closed')
  closed,
}

enum InquiryCategory {
  @JsonValue('general')
  general,
  @JsonValue('bug')
  bug,
  @JsonValue('feature')
  feature,
  @JsonValue('account')
  account,
  @JsonValue('recipe')
  recipe,
  @JsonValue('audio')
  audio,
  @JsonValue('ui')
  ui,
  @JsonValue('performance')
  performance,
}

extension InquiryStatusExtension on InquiryStatus {
  String get displayName {
    switch (this) {
      case InquiryStatus.pending:
        return '답변 대기';
      case InquiryStatus.answered:
        return '답변 완료';
      case InquiryStatus.closed:
        return '해결 완료';
    }
  }
  
  String get displayEmoji {
    switch (this) {
      case InquiryStatus.pending:
        return '⏳';
      case InquiryStatus.answered:
        return '✅';
      case InquiryStatus.closed:
        return '🔒';
    }
  }
}

extension InquiryCategoryExtension on InquiryCategory {
  String get displayName {
    switch (this) {
      case InquiryCategory.general:
        return '일반 문의';
      case InquiryCategory.bug:
        return '버그 신고';
      case InquiryCategory.feature:
        return '기능 제안';
      case InquiryCategory.account:
        return '계정 문의';
      case InquiryCategory.recipe:
        return '레시피 관련';
      case InquiryCategory.audio:
        return '음성 관련';
      case InquiryCategory.ui:
        return 'UI/UX 관련';
      case InquiryCategory.performance:
        return '성능 관련';
    }
  }
  
  String get displayEmoji {
    switch (this) {
      case InquiryCategory.general:
        return '💬';
      case InquiryCategory.bug:
        return '🐛';
      case InquiryCategory.feature:
        return '💡';
      case InquiryCategory.account:
        return '👤';
      case InquiryCategory.recipe:
        return '🍳';
      case InquiryCategory.audio:
        return '🎤';
      case InquiryCategory.ui:
        return '🎨';
      case InquiryCategory.performance:
        return '⚡';
    }
  }
}

@JsonSerializable()
class Inquiry {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String title;
  final String content;
  final InquiryCategory category;
  final InquiryStatus status;
  @JsonKey(name: 'admin_response')
  final String? adminResponse;
  @JsonKey(name: 'admin_response_at')
  final DateTime? adminResponseAt;
  @JsonKey(name: 'admin_id')
  final String? adminId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Inquiry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.status,
    this.adminResponse,
    this.adminResponseAt,
    this.adminId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) => _$InquiryFromJson(json);
  Map<String, dynamic> toJson() => _$InquiryToJson(this);

  bool get hasResponse => adminResponse != null && adminResponse!.isNotEmpty;
  
  @override
  String toString() {
    return 'Inquiry(id: $id, title: $title, status: $status, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Inquiry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class InquiryListItem {
  final String id;
  final String title;
  final InquiryCategory category;
  final InquiryStatus status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'has_response')
  final bool hasResponse;

  InquiryListItem({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.hasResponse,
  });

  factory InquiryListItem.fromJson(Map<String, dynamic> json) => _$InquiryListItemFromJson(json);
  Map<String, dynamic> toJson() => _$InquiryListItemToJson(this);

  @override
  String toString() {
    return 'InquiryListItem(id: $id, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InquiryListItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class InquiryStats {
  final int total;
  final int pending;
  final int answered;
  final int closed;

  InquiryStats({
    required this.total,
    required this.pending,
    required this.answered,
    required this.closed,
  });

  factory InquiryStats.fromJson(Map<String, dynamic> json) => _$InquiryStatsFromJson(json);
  Map<String, dynamic> toJson() => _$InquiryStatsToJson(this);

  @override
  String toString() {
    return 'InquiryStats(total: $total, pending: $pending, answered: $answered, closed: $closed)';
  }
}

@JsonSerializable()
class InquiryCreateRequest {
  final String title;
  final String content;
  final InquiryCategory category;

  InquiryCreateRequest({
    required this.title,
    required this.content,
    required this.category,
  });

  factory InquiryCreateRequest.fromJson(Map<String, dynamic> json) => _$InquiryCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$InquiryCreateRequestToJson(this);
}

@JsonSerializable()
class InquiryUpdateRequest {
  final String? title;
  final String? content;
  final InquiryCategory? category;

  InquiryUpdateRequest({
    this.title,
    this.content,
    this.category,
  });

  factory InquiryUpdateRequest.fromJson(Map<String, dynamic> json) => _$InquiryUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$InquiryUpdateRequestToJson(this);
}