import 'package:markit_place_front/domain/members/models/session_user.dart';

// 로그인 API 성공 시 'response' 필드 내부의 실제 상세 데이터를 위한 DTO
// 이 클래스는 ApiResponseDto<T>의 T로 사용됩니다.
class LoginResponseDataDto {
  final int id;
  final String loginId;
  final String? name; // 이름은 nullable일 수 있음
  final String role; // 역할 필드 추가 (non-nullable)
  // 서버 응답에 status 필드도 있었지만, SessionUser에서 현재 사용하지 않으므로 DTO에서도 일단 제외하거나 필요시 추가

  LoginResponseDataDto({
    required this.id,
    required this.loginId,
    this.name,
    required this.role, // 생성자에 role 추가
  });

  factory LoginResponseDataDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDataDto(
      id: json['id'] as int,
      loginId: json['loginId'] as String,
      name: json['name'] as String?,
      role: json['role'] as String, // fromJson에 role 추가
    );
  }

  // 이 DTO를 SessionUser 모델로 변환하는 메소드
  SessionUser toSessionUser() {
    return SessionUser(
      memberId: id,
      loginId: loginId,
      name: name,
      role: role, // SessionUser 생성자에 role 전달
    );
  }

  // LoginResponseDataDto 객체를 JSON으로 변환하는 메소드 (주로 요청 시에는 사용되지 않음)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loginId': loginId,
      'name': name,
      'role': role, // toJson에 role 추가
    };
  }
}
