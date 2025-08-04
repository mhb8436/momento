import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@JsonSerializable()
@HiveType(typeId: 3)
class User {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String email;
  @JsonKey(name: 'full_name')
  @HiveField(2)
  final String? fullName;
  @JsonKey(name: 'profile_image_url')
  @HiveField(3)
  final String? profileImageUrl;
  @JsonKey(name: 'is_active')
  @HiveField(4)
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.profileImageUrl,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? profileImageUrl,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, profileImageUrl: $profileImageUrl, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.profileImageUrl == profileImageUrl &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        fullName.hashCode ^
        profileImageUrl.hashCode ^
        isActive.hashCode;
  }
}