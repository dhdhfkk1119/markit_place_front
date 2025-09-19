// lib/domain/members/dtos/my_profile_response_data_dto.dart
import '../models/session_user.dart';

// GET /api/members/me API의 'response' 필드 내부 상세 데이터를 위한 DTO
class MyProfileResponseDataDto {
  final int id;
  final String? loginId;
  final String? email;
  final String? name;
  final String role;
  final String? status;
  final String? profileImageBase64; // 프로필 사진의 Base64 인코딩된 문자열

  MyProfileResponseDataDto({
    required this.id,
    this.loginId,
    this.email,
    this.name,
    required this.role,
    this.status,
    this.profileImageBase64,
  });

  factory MyProfileResponseDataDto.fromJson(Map<String, dynamic> json) {
    return MyProfileResponseDataDto(
      id: json['id'] as int,
      loginId: json['loginId'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String,
      status: json['status'] as String?,
      profileImageBase64: json['profileImageBase64'] as String?,
    );
  }

  // 이 DTO를 SessionUser 모델로 변환하는 메소드
  SessionUser toSessionUser() {
    String? finalProfileImageUrl;
    if (profileImageBase64 != null && profileImageBase64!.isNotEmpty) {
      // Base64 문자열로 데이터 URI 생성 (이미지 타입은 PNG로 가정, 필요시 수정)
      // 실제 이미지 타입에 따라 'image/jpeg', 'image/gif' 등으로 변경 가능
      // 서버에서 이미지 타입을 명시적으로 알려주지 않으면, 일반적인 타입을 사용하거나,
      // Base64 문자열 자체에서 타입을 추론하는 로직이 필요할 수 있음 (더 복잡)
      finalProfileImageUrl = 'data:image/png;base64,$profileImageBase64';
    }

    return SessionUser(
      memberId: id,
      loginId: loginId,
      email: email,
      name: name,
      role: role,
      profileImageUrl: finalProfileImageUrl, // 변환된 데이터 URI 또는 null
    );
  }
}
