class SocialLoginRequestDto {
  final String provider;
  final String providerId;
  final String email;

  SocialLoginRequestDto({
    required this.provider,
    required this.providerId,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'providerId': providerId,
        'email': email,
      };
}
