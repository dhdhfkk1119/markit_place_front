class SessionUser {
  final int memberId; // 서버의 Member ID
  final String loginId;
  final String? name; // 이름은 null일 수 있음
  final String role; // 역할 필드 추가 (non-nullable)

  SessionUser({
    required this.memberId,
    required this.loginId,
    this.name,
    required this.role, // 생성자에 role 추가
  });

  // JSON으로부터 SessionUser 객체를 생성하는 팩토리 생성자
  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      memberId: json['memberId'] as int,
      loginId: json['loginId'] as String,
      name: json['name'] as String?,
      role: json['role'] as String, // fromJson에 role 추가
    );
  }

  // SessionUser 객체를 JSON으로 변환하는 메서드 (필요한 경우)
  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'loginId': loginId,
      'name': name,
      'role': role, // toJson에 role 추가
    };
  }
}
