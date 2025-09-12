// lib/domain/models/user.dart

import 'package:logger/logger.dart';
import 'package:markit_place_front/domain/dtos/user_dto.dart';

enum MemberStatus {
  ACTIVE,
  WITHDRAWN,
  BANNED,
}

class User {
  final int id;
  final String loginId;
  final String name;
  final MemberStatus status;

  User({
    required this.id,
    required this.loginId,
    required this.name,
    required this.status,
  });

  factory User.fromDto(UserDto dto) {
    return User(
      id: dto.id,
      loginId: dto.loginId,
      name: dto.name,
      status: _parseStatus(dto.status),
    );
  }

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
