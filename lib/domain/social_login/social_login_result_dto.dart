import '../members/models/session_user.dart';

class SocialLoginResultDto {
  final SessionUser? sessionUser;
  final String? token;
  final String? socialAccountName;
  final String? socialProfileImageBase64;

  SocialLoginResultDto({
    this.sessionUser,
    this.token,
    this.socialAccountName,
    this.socialProfileImageBase64,
  });
}
