/// 비밀번호 재설정 단계에서 사용되는 다양한 요청 및 응답 DTO를 정의합니다.

/// 1. 비밀번호 재설정 코드 발송 요청 DTO
class SendPasswordResetCodeRequestDto {
  final String loginId; // 사용자가 입력한 로그인 ID
  final String email; // 사용자가 입력한 이메일

  SendPasswordResetCodeRequestDto({
    required this.loginId,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'loginId': loginId,
      'email': email,
    };
  }
}

/// 2. 비밀번호 재설정 코드 확인 요청 DTO
class ConfirmPasswordResetCodeRequestDto {
  final String email; // 코드가 발송된 이메일 주소
  final String code; // 사용자가 입력한 인증 코드

  ConfirmPasswordResetCodeRequestDto({
    required this.email,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }
}

/// 3. 비밀번호 재설정 (최종) 요청 DTO
class PasswordResetRequestDto {
  final String tempToken; // 코드 확인 후 발급받은 임시 토큰 (클라이언트 내부 변수명 유지)
  final String newPassword;
  // confirmNewPassword 필드는 생성자에는 유지 (클라이언트측 유효성 검사용)
  // 하지만 toJson에서는 제외됨
  final String confirmNewPassword;

  PasswordResetRequestDto({
    required this.tempToken,
    required this.newPassword,
    required this.confirmNewPassword, // 생성자에는 유지
  });

  Map<String, dynamic> toJson() {
    // 서버 명세에 따라 'resetToken' 키 사용 및 'confirmNewPassword' 필드 제거
    return {
      'resetToken': tempToken, // 키 이름 'resetToken'으로 변경
      'newPassword': newPassword,
      // 'confirmNewPassword' 필드는 서버 요청 본문에 포함하지 않음
    };
  }
}

/// 4. 비밀번호 재설정 코드 확인 응답 DTO (임시 토큰 포함)
class PasswordResetTokenResponseDto {
  final String tempToken; // 클래스 필드명은 tempToken으로 유지 (PasswordResetState와 일관성)

  PasswordResetTokenResponseDto({required this.tempToken});

  factory PasswordResetTokenResponseDto.fromJson(Map<String, dynamic> json) {
    // 서버 응답의 JSON 키는 'resetToken'이므로 여기서 매핑
    final tokenFromServer = json['resetToken'];
    if (tokenFromServer == null) {
      print(
          "[PasswordResetTokenResponseDto] 'resetToken' is null or missing in response json: $json");
      throw Exception("'resetToken'이 서버 응답에 없습니다.");
    }
    return PasswordResetTokenResponseDto(
      tempToken: tokenFromServer as String,
    );
  }
}
