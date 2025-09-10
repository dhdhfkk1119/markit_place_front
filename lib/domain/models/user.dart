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
        loginId = data['username'],
        name = data['imgUrl'],
        status = data['status'];
}
