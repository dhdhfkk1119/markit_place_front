// D:/workspace-flutter/markit_place_front/lib/domain/members/models/session_user.dart
class SessionUser {
  final int memberId;
  final String? loginId;
  final String? email;
  final String? name; // 'nickname' 대신 기존 'name' 필드 활용 또는 추후 nickname 추가 논의
  final String role;
  final String? profileImageUrl;
  final int? mannerScore;
  final int? retransactionRate; // API 응답 필드명과 일치시키거나 DTO에서 변환 시 매핑 주의
  final String? userCode;

  SessionUser({
    required this.memberId,
    this.loginId,
    this.email,
    this.name,
    required this.role,
    this.profileImageUrl,
    this.mannerScore,
    this.retransactionRate,
    this.userCode,
  });

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      memberId: json['memberId'] as int,
      loginId: json['loginId'] as String?,
      email: json['email'] as String?,
      name: json['name']
          as String?, // 'nickname' 키가 있다면 json['nickname'] ?? json['name'] 고려
      role: json['role'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      mannerScore: json['mannerScore'] as int?,
      retransactionRate: json['retransactionRate']
          as int?, // 또는 json['reTransactionRate'] 등 실제 키 확인 필요
      userCode: json['userCode'] as String?,
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
      'mannerScore': mannerScore,
      'retransactionRate': retransactionRate,
      'userCode': userCode,
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
    int? mannerScore,
    int? retransactionRate,
    String? userCode,
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
      mannerScore: mannerScore ?? this.mannerScore,
      retransactionRate: retransactionRate ?? this.retransactionRate,
      userCode: userCode ?? this.userCode,
    );
  }
}
