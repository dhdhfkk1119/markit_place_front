// lib/members/models/member.dart
import 'package:logger/logger.dart';

enum MemberStatus {
  ACTIVE,
  WITHDRAWN,
  BANNED,
}

class Member {
  final int? id;
  final String loginId;
  final String? name; // MemberProfile의 name(닉네임)과 대응될 수 있음
  final String? email;
  final String? password; // 요청 시에만 사용, 응답에는 포함되지 않음
  final MemberStatus? status;
  final String? role;
  final bool? isEmailVerified;
  final List<int>? agreedTermIds; // 회원가입 시 사용

  /// MemberProfile 정보 (nullable)
  final String? profileImageBase64;
  final double? temperature;
  final double? retradeRate;
  final double? responseRate;
  final DateTime? lastActiveAt;

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

    /// MemberProfile 칼럼들
    this.profileImageBase64,
    this.temperature,
    this.retradeRate,
    this.responseRate,
    this.lastActiveAt,
  });

  Member.fromMap(Map<String, dynamic> data)
      : id = data['id'] as int?,
        loginId = data['loginId'] as String,
        name = data['name'] as String?,
        email = data['email'] as String?,
        password = null, // 서버에서 사용자 정보 조회 시 비밀번호는 내려오지 않음
        status = data['status'] != null
            ? _parseStatus(data['status']! as String)
            : null,
        role = data['role'] as String?,
        isEmailVerified = data['isEmailVerified'] as bool?,
        agreedTermIds = null, // 보통 사용자 정보 조회 시 내려오지 않음, 필요시 추가 파싱
        // Profile fields from map
        profileImageBase64 = data['profileImageBase64'] as String?,
        temperature = (data['temperature'] as num?)
            ?.toDouble(), // JSON의 숫자는 num, double로 캐스팅
        retradeRate = (data['retradeRate'] as num?)?.toDouble(),
        responseRate = (data['responseRate'] as num?)?.toDouble(),
        lastActiveAt = data['lastActiveAt'] != null
            ? DateTime.tryParse(data['lastActiveAt'] as String)
            : null;

  factory Member.forRegistration({
    required String loginId,
    required String password,
    required String email,
    String? name, // 가입 시 이름(닉네임)을 받을 수 있다면 여기에 포함
    bool isEmailVerified = false,
    required List<int> agreedTermIds,
  }) {
    return Member(
      loginId: loginId,
      password: password,
      email: email,
      name:
          name, // MemberProfile.name에 해당하는 닉네임을 여기서 받을지, 아니면 Profile 수정 시 받을지 정책 필요
      isEmailVerified: isEmailVerified,
      agreedTermIds: agreedTermIds,
      id: null,
      status: null,
      role: null,
      // Profile 필드들은 가입 시점에는 보통 null이거나 기본값이므로 명시적으로 설정 안 함
      // 필요하다면 기본값 설정 가능 (예: temperature: 36.5)
    );
  }

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

  // TODO: Member 객체를 Map으로 변환하는 toJson() 메소드 (API 요청 시 필요할 수 있음, 예: 프로필 업데이트)
  // Map<String, dynamic> toJson() { ... }
}
