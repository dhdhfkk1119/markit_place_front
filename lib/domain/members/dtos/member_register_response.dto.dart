import '../../../domain/members/models/member.dart'; // MemberStatus enum을 위해 유지

// 'response' 필드 내부의 실제 상세 데이터를 위한 DTO
// 이 클래스는 ApiResponseDto<T>의 T로 사용됩니다.
class MemberRegisterResponseDataDto {
  final int id;
  final String loginId;
  final String? name;
  final String role;
  final MemberStatus status;

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
      // email, password, isEmailVerified, agreedTermIds 등은
      // 이 DTO에 포함되지 않으므로, Member 모델 기본값 또는 null로 설정됩니다.
    );
  }

  // MemberStatus 파싱 로직 (기존과 동일)
  static MemberStatus _parseStatusSafe(String? statusString) {
    if (statusString == null) return MemberStatus.ACTIVE; // 기본값 또는 서버 명세에 따름
    final lowerStatus = statusString.toLowerCase();
    if (lowerStatus == 'active') {
      return MemberStatus.ACTIVE;
    } else if (lowerStatus == 'withdrawn') {
      return MemberStatus.WITHDRAWN;
    } else if (lowerStatus == 'banned') {
      return MemberStatus.BANNED;
    }
    // 알 수 없는 상태값에 대한 기본 처리 (예: 로깅 후 기본값 반환)
    // Logger().w("Unknown member status from server: $statusString");
    return MemberStatus.ACTIVE;
  }
}
