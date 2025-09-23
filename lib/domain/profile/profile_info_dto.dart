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
    // profileImageBase64가 없으면 profileImageUrl 또는 빈 문자열로 대체
    final dynamic img =
        res['profileImageBase64'] ?? res['profileImageUrl'] ?? '';

    // id를 안전하게 파싱 (int 또는 문자열로 올 수 있음)
    int parseId(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return ProfileInfoResponseDto(
      id: parseId(res['id']),
      name: (res['name'] ?? '').toString(),
      profileImageBase64: img == null ? '' : img.toString(),
    );
  }
}
