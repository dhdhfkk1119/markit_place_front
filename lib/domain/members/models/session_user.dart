class SessionUser {
  final int memberId; // 서버의 Member ID
  final String? loginId; // String -> String? 으로 변경
  final String? name; // 이미 String?으로 잘 되어 있음
  final String role; // 역할 필드 추가 (non-nullable)

  SessionUser({
    required this.memberId,
    this.loginId, // required 제거 또는 그대로 두되, null을 받을 수 있도록 함
    this.name,
    required this.role,
  });

  // JSON으로부터 SessionUser 객체를 생성하는 팩토리 생성자
  // 이 파일에서 직접 사용되진 않지만, 만약 다른 곳에서 SessionUser.fromJson을 호출한다면 수정 필요
  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      memberId: json['memberId'] as int,
      loginId: json['loginId'] as String?, // String -> String? 으로 변경
      name: json['name'] as String?,
      role: json['role'] as String,
    );
  }

  // SessionUser 객체를 JSON으로 변환하는 메서드 (필요한 경우)
  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'loginId': loginId,
      'name': name,
      'role': role,
    };
  }
}
