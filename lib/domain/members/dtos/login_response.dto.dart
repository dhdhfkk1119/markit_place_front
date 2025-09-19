import 'package:markit_place_front/domain/members/models/session_user.dart';

// 로그인 API 성공 시 'response' 필드 내부의 실제 상세 데이터를 위한 DTO
// 이 클래스는 ApiResponseDto<T>의 T로 사용됩니다.
class LoginResponseDataDto {
  final int id;
  final String? loginId; // String -> String? 으로 변경
  final String? name; // 이미 String?으로 잘 되어 있음
  final String role;
  final String? status; // 서버 응답에 status 필드가 있었으므로 DTO에 추가 (nullable)

  LoginResponseDataDto({
    required this.id,
    this.loginId,
    this.name,
    required this.role,
    this.status, // 생성자에 status 추가
  });

  factory LoginResponseDataDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDataDto(
      id: json['id'] as int,
      loginId: json['loginId'] as String?, // String -> String? 으로 변경
      name: json['name'] as String?,
      role: json['role'] as String,
      status: json['status'] as String?, // status 필드 파싱 추가
    );
  }

  // 이 DTO를 SessionUser 모델로 변환하는 메소드
  SessionUser toSessionUser() {
    return SessionUser(
      memberId: id,
      loginId: loginId, // SessionUser.loginId가 String?이므로, null 값을 그대로 전달
      name: name,
      role: role,
    );
  }

  // LoginResponseDataDto 객체를 JSON으로 변환하는 메소드 (주로 요청 시에는 사용되지 않음)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loginId': loginId,
      'name': name,
      'role': role,
      'status': status, // toJson에 status 추가
    };
  }
}
