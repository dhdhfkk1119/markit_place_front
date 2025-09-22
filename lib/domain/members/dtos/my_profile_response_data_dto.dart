// lib/domain/members/dtos/my_profile_response_data_dto.dart
import '../../../_core/sessions/session_user.dart';

// GET /api/members/me API의 'response' 필드 내부 상세 데이터를 위한 DTO
class MyProfileResponseDataDto {
  final int id;
  final String? loginId;
  final String? email;
  final String?
      name; // 서버에서 'nickname'으로 올 경우, 이 필드에 매핑하거나 SessionUser에 nickname 필드 추가 고려
  final String role;
  final String? status;
  final String? profileImageBase64;

  // 추가된 필드 (백엔드 /api/members/me 응답에 이 필드들이 포함되어야 함)
  final int? mannerScore;
  final int? retransactionRate; // API 응답 필드명 확인 필요 (예: reTransactionRate)
  final String? userCode;

  MyProfileResponseDataDto({
    required this.id,
    this.loginId,
    this.email,
    this.name,
    required this.role,
    this.status,
    this.profileImageBase64,
    this.mannerScore,
    this.retransactionRate,
    this.userCode,
  });

  factory MyProfileResponseDataDto.fromJson(Map<String, dynamic> json) {
    return MyProfileResponseDataDto(
      id: json['id'] as int,
      loginId: json['loginId'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String? ??
          json['nickname'] as String?, // 'nickname'도 고려
      role: json['role'] as String,
      status: json['status'] as String?,
      profileImageBase64: json['profileImageBase64'] as String?,
      // 추가된 필드 파싱 (백엔드 응답 키와 일치해야 함)
      mannerScore: json['mannerScore'] as int?,
      retransactionRate: json['retransactionRate'] as int? ??
          json['reTransactionRate'] as int?, // 실제 API 응답 키 확인
      userCode: json['userCode'] as String?,
    );
  }

  // 이 DTO를 SessionUser 모델로 변환하는 메소드
  SessionUser toSessionUser() {
    String? finalProfileImageUrl;
    if (profileImageBase64 != null && profileImageBase64!.isNotEmpty) {
      finalProfileImageUrl = 'data:image/png;base64,$profileImageBase64';
    }

    return SessionUser(
      memberId: id,
      loginId: loginId,
      email: email,
      name: name,
      role: role,
      profileImageUrl: finalProfileImageUrl,
      // 추가된 필드 매핑
      mannerScore: mannerScore,
      retransactionRate: retransactionRate,
      userCode: userCode,
    );
  }
}
