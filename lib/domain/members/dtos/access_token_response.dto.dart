// D:/workspace-flutter/markit_place_front/lib/domain/members/dtos/access_token_response.dto.dart
class AccessTokenResponseDataDto {
  final String accessToken;

  AccessTokenResponseDataDto({required this.accessToken});

  factory AccessTokenResponseDataDto.fromJson(Map<String, dynamic> json) {
    return AccessTokenResponseDataDto(
      accessToken: json['accessToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
    };
  }
}
