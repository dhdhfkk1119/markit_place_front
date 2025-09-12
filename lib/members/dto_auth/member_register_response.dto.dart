// lib/members/dto_auth/member_register_response.dto.dart
import '../../../_core/dtos/error_dto.dart'; // 공용 ErrorDto import
import '../domains/member.dart'; // Member 및 MemberStatus enum import

// 서버의 기본 응답 래퍼 DTO
class MemberRegisterResponseDto {
  final bool success;
  final MemberRegisterResponseDataDto? response;
  final ErrorDto? error;

  MemberRegisterResponseDto({
    required this.success,
    this.response,
    this.error,
  });

  factory MemberRegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return MemberRegisterResponseDto(
      success: json['success'] as bool,
      response: json['response'] != null
          ? MemberRegisterResponseDataDto.fromJson(
              json['response'] as Map<String, dynamic>)
          : null,
      error: json['error'] != null
          ? ErrorDto.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }
}

// 'response' 필드 내부의 상세 데이터를 위한 DTO
class MemberRegisterResponseDataDto {
  final int id;
  final String loginId;
  final String? name;
  final String role;
  final MemberStatus status; // 이제 명확히 member.dart의 MemberStatus를 참조

  MemberRegisterResponseDataDto({
    required this.id,
    required this.loginId,
    this.name,
    required this.role,
    required this.status,
  });

  factory MemberRegisterResponseDataDto.fromJson(Map<String, dynamic> json) {
    return MemberRegisterResponseDataDto(
      id: json['id'] as int,
      loginId: json['loginId'] as String,
      name: json['name'] as String?,
      role: json['role'] as String,
      status: _parseStatusSafe(json['status'] as String?),
    );
  }

  Member toMember() {
    return Member(
      id: id,
      loginId: loginId,
      name: name,
      status: status,
      role: role,
    );
  }

  static MemberStatus _parseStatusSafe(String? statusString) {
    if (statusString == null) return MemberStatus.ACTIVE;
    final lowerStatus = statusString.toLowerCase();
    if (lowerStatus == 'active') {
      return MemberStatus.ACTIVE;
    } else if (lowerStatus == 'withdrawn') {
      return MemberStatus.WITHDRAWN;
    } else if (lowerStatus == 'banned') {
      return MemberStatus.BANNED;
    }
    return MemberStatus.ACTIVE;
  }
}
