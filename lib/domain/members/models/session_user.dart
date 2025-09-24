// D:/workspace-flutter/markit_place_front/lib/domain/members/models/session_user.dart
class SessionUser {
  final int memberId;
  final String? loginId;
  final String? email;
  final String? name; // 'nickname' 대신 기존 'name' 필드 활용 또는 추후 nickname 추가 논의
  final String role;
  final String? provider; // <<< provider 필드 추가
  final String? profileImageUrl;
  final String? profileImageBase64; // 새로 추가된 필드
  final int? mannerScore;
  final int? retransactionRate; // API 응답 필드명과 일치시키거나 DTO에서 변환 시 매핑 주의
  final String? userCode;

  SessionUser({
    required this.memberId,
    this.loginId,
    this.email,
    this.name,
    required this.role,
    this.provider, // <<< 생성자에 provider 추가
    this.profileImageUrl,
    this.profileImageBase64,
    this.mannerScore,
    this.retransactionRate,
    this.userCode,
  });

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      memberId: json['memberId'] as int,
      loginId: json['loginId'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String,
      provider: json['provider'] as String?, // <<< json에서 provider 매핑
      profileImageUrl: json['profileImageUrl'] as String?,
      profileImageBase64: json['profileImageBase64'] as String?,
      mannerScore: json['mannerScore'] as int?,
      retransactionRate: json['retransactionRate'] as int?,
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
      'provider': provider, // <<< toJson에 provider 추가
      'profileImageUrl': profileImageUrl,
      'profileImageBase64': profileImageBase64,
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
    String? provider, // <<< copyWith에 provider 파라미터 추가
    String? profileImageUrl,
    String? profileImageBase64,
    bool allowNullProfileImageUrl = false,
    bool allowNullProfileImageBase64 = false,
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
      provider: provider ?? this.provider, // <<< copyWith 로직에 provider 추가
      profileImageUrl: allowNullProfileImageUrl
          ? profileImageUrl
          : profileImageUrl ?? this.profileImageUrl,
      profileImageBase64: allowNullProfileImageBase64
          ? profileImageBase64
          : profileImageBase64 ?? this.profileImageBase64,
      mannerScore: mannerScore ?? this.mannerScore,
      retransactionRate: retransactionRate ?? this.retransactionRate,
      userCode: userCode ?? this.userCode,
    );
  }
}
