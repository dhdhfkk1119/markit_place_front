import 'package:markit_place_front/domain/members/models/session_user.dart';

// 로그인 API 성공 시 'response' 필드 내부의 실제 상세 데이터를 위한 DTO
// 이 클래스는 ApiResponseDto<T>의 T로 사용됩니다.
class LoginResponseDataDto {
  final int id;
  final String loginId;
  final String? name; // 이름은 nullable일 수 있음
  final String? email; // 이메일은 nullable일 수 있음
  // final String role;

  LoginResponseDataDto({
    required this.id,
    required this.loginId,
    this.name,
    this.email,
    // required this.role,
  });

  factory LoginResponseDataDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDataDto(
      id: json['id'] as int,
      loginId: json['loginId'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      // role: json['role'] as String, // 서버 응답에 role이 없을 수 있고, 클라이언트에서 사용 안 함
    );
  }

  // 이 DTO를 SessionUser 모델로 변환하는 메소드
  SessionUser toSessionUser() {
    return SessionUser(
      memberId: id, // SessionUser의 memberId 필드 사용
      loginId: loginId,
      name: name,
      // role: role, // SessionUser 모델에서도 role 필드를 주석/제거 예정
    );
  }

  // LoginResponseDataDto 객체를 JSON으로 변환하는 메소드 (주로 요청 시에는 사용되지 않음)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loginId': loginId,
      'name': name,
      'email': email,
      // 'role': role,
    };
  }
}
