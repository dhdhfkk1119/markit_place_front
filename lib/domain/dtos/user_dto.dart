class UserDto {
  final int id;
  final String loginId;
  final String name;
  final String status;

  UserDto({
    required this.id,
    required this.loginId,
    required this.name,
    required this.status,
  });

  // Map에서 Dto로 변환하는 팩토리 생성자
  factory UserDto.fromMap(Map<String, dynamic> data) {
    return UserDto(
      id: data['id'],
      loginId: data['loginId'],
      name: data['name'],
      status: data['status'],
    );
  }
}
