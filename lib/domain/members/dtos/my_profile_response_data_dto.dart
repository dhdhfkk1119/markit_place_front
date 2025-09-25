// lib/domain/members/dtos/my_profile_response_data_dto.dart
import '../models/session_user.dart';

class MyProfileResponseDataDto {
  final int id;
  final String? loginId;
  final String? email;
  final String? name;
  final String role; // String? 에서 String 으로 변경
  final String status;
  final String? provider; // <<< provider 필드 추가
  final String? profileImageBase64;
  final String? profileImageUrl;
  final int? mannerScore;
  final int? retransactionRate;
  final String? userCode;

  MyProfileResponseDataDto({
    required this.id,
    this.loginId,
    this.email,
    this.name,
    required this.role, // required 추가
    required this.status,
    this.provider, // <<< 생성자에 provider 추가
    this.profileImageBase64,
    this.profileImageUrl,
    this.mannerScore,
    this.retransactionRate,
    this.userCode,
  });

  factory MyProfileResponseDataDto.fromJson(Map<String, dynamic> json) {
    return MyProfileResponseDataDto(
      id: json['id'] as int,
      loginId: json['loginId'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String, // String? 에서 String 으로 변경
      status: json['status'] as String,
      provider: json['provider'] as String?, // <<< json에서 provider 매핑
      profileImageBase64: json['profileImageBase64'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      mannerScore: json['mannerScore'] as int?,
      retransactionRate: json['retransactionRate'] as int? ??
          json['reTransactionRate'] as int?,
      userCode: json['userCode'] as String?,
    );
  }

  SessionUser toSessionUser() {
    // 파라미터 제거
    return SessionUser(
      memberId: id,
      loginId: loginId,
      email: email,
      name: name,
      role: this.role, // DTO의 role 직접 사용
      provider: provider, // <<< SessionUser 생성 시 provider 전달
      profileImageUrl: profileImageUrl,
      profileImageBase64: profileImageBase64,
      mannerScore: mannerScore,
      retransactionRate: retransactionRate,
      userCode: userCode,
    );
  }
}
