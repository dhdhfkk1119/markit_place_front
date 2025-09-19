// D:/workspace-flutter/markit_place_front/lib/domain/members/models/session_user.dart
class SessionUser {
  final int memberId;
  final String? loginId;
  final String? email;
  final String? name;
  final String role;
  final String? profileImageUrl;

  SessionUser({
    required this.memberId,
    this.loginId,
    this.email,
    this.name,
    required this.role,
    this.profileImageUrl,
  });

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      memberId: json['memberId'] as int,
      loginId: json['loginId'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'loginId': loginId,
      'email': email,
      'name': name,
      'role': role,
      'profileImageUrl': profileImageUrl,
    };
  }

  SessionUser copyWith({
    int? memberId,
    String? loginId,
    String? email,
    String? name,
    String? role,
    String? profileImageUrl,
    bool allowNullProfileImageUrl = false,
  }) {
    return SessionUser(
      memberId: memberId ?? this.memberId,
      loginId: loginId ?? this.loginId,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImageUrl: allowNullProfileImageUrl
          ? profileImageUrl
          : profileImageUrl ?? this.profileImageUrl,
    );
  }
}
