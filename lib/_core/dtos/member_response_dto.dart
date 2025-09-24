class MemberResponseDto {
  final bool success;
  final MemberData response;
  final dynamic error;

  MemberResponseDto({
    required this.success,
    required this.response,
    this.error,
  });

  factory MemberResponseDto.fromJson(Map<String, dynamic> json) {
    return MemberResponseDto(
      success: json['success'],
      response: MemberData.fromJson(json['response']),
      error: json['error'],
    );
  }
}

class MemberData {
  final int id;
  final String loginId;
  final String email;
  final String name;
  final String role;
  final String status;
  final String provider;
  final String profileImageBase64;

  MemberData({
    required this.id,
    required this.loginId,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.provider,
    required this.profileImageBase64,
  });

  factory MemberData.fromJson(Map<String, dynamic> json) {
    return MemberData(
      id: json['id'],
      loginId: json['loginId'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      status: json['status'],
      provider: json['provider'],
      profileImageBase64: json['profileImageBase64'],
    );
  }
}
