class SocialLoginResponseDataDto {
  final int id;
  final String email;

  SocialLoginResponseDataDto({
    required this.id,
    required this.email,
  });

  factory SocialLoginResponseDataDto.fromJson(Map<String, dynamic> json) {
    return SocialLoginResponseDataDto(
      id: json['id'] as int,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }
}
