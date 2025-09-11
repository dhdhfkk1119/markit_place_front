// domain/models/user.dart 파일 수정
import 'package:logger/logger.dart';

enum MemberStatus {
  ACTIVE,
  WITHDRAWN,
  BANNED,
}

class User {
  final int id;
  final String loginId;
  final String? name;
  final MemberStatus status;

  User({
    required this.id,
    required this.loginId,
    this.name,
    required this.status,
  });

  User.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        // 서버 응답과 일치하도록 수정
        loginId = data['loginId'],
        // 서버 응답과 일치하도록 수정
        name = data['name'],
        // 문자열 상태값을 MemberStatus enum으로 변환
        status = _parseStatus(data['status']);

  static MemberStatus _parseStatus(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'active') {
      return MemberStatus.ACTIVE;
    } else if (lowerStatus == 'withdrawn') {
      return MemberStatus.WITHDRAWN;
    } else if (lowerStatus == 'banned') {
      return MemberStatus.BANNED;
    } else {
      Logger().w("알 수 없는 회원 상태: $status");
      return MemberStatus.ACTIVE;
    }
  }
}
