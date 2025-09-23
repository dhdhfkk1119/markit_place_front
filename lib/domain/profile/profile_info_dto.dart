// 프로필 정보 조회 응답 DTO
class ProfileInfoResponseDto {
  final int id;
  final String name;
  final String profileImageBase64;

  ProfileInfoResponseDto({
    required this.id,
    required this.name,
    required this.profileImageBase64,
  });

  factory ProfileInfoResponseDto.fromJson(Map<String, dynamic> json) {
    final res = json['response'] ?? {};
    return ProfileInfoResponseDto(
      id: res['id'],
      name: res['name'],
      profileImageBase64: res['profileImageBase64'],
    );
  }
}
