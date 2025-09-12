// lib/members/domains/member.dart
import 'package:logger/logger.dart';

enum MemberStatus {
  ACTIVE,
  WITHDRAWN,
  BANNED,
}

class Member {
  final int? id; // 기존 id, 회원가입 시에는 null일 수 있음
  final String loginId; // 로그인 ID는 필수
  final String? name; // 이름
  final String? email; // 이메일 (MemberRegisterRequestUiModel 에서 통합)
  final String?
      password; // 비밀번호 (MemberRegisterRequestUiModel 에서 통합, 요청 시에만 사용)
  final MemberStatus? status; // 상태, 회원가입 시에는 null이거나 기본값일 수 있음
  final String? role; // 역할, 회원가입 시에는 null이거나 기본값일 수 있음
  final bool? isEmailVerified; // 이메일 인증 여부 (MemberRegisterRequestUiModel 에서 통합)
  final List<int>?
      agreedTermIds; // 동의한 약관 ID 목록 (MemberRegisterRequestUiModel 에서 통합)

  Member({
    required this.loginId,
    this.id,
    this.name,
    this.email,
    this.password,
    this.status,
    this.role,
    this.isEmailVerified,
    this.agreedTermIds,
  });

  Member.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        loginId = data['loginId'], // 서버에서 받아오는 데이터에는 loginId가 항상 있다고 가정
        name = data['name'],
        email = data['email'],
        password = null, // 서버에서 사용자 정보 조회 시 비밀번호는 내려오지 않음
        status = data['status'] != null ? _parseStatus(data['status']!) : null,
        role = data['role'],
        isEmailVerified = data['isEmailVerified'],
        agreedTermIds = null; // 약관 동의 목록은 보통 사용자 정보 조회 시 내려오지 않음

  static MemberStatus _parseStatus(String statusValue) {
    final lowerStatus = statusValue.toLowerCase();
    if (lowerStatus == 'active') {
      return MemberStatus.ACTIVE;
    } else if (lowerStatus == 'withdrawn') {
      return MemberStatus.WITHDRAWN;
    } else if (lowerStatus == 'banned') {
      return MemberStatus.BANNED;
    } else {
      Logger().w("Unknown member status: $statusValue");
      return MemberStatus.ACTIVE; // 기본 상태 반환
    }
  }
}
