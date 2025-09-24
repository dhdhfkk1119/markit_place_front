// 프로필 정보 조회 응답 DTO
class ProfileInfoResponseDto {
  final int id;
  final String name;
  final String nickname;
  final String profileImageBase64;
  final String profileImageUrl;

  ProfileInfoResponseDto({
    required this.id,
    required this.name,
    required this.nickname,
    required this.profileImageBase64,
    required this.profileImageUrl,
  });

  factory ProfileInfoResponseDto.fromJson(Map<String, dynamic> json) {
    final res = json['response'] ?? {};
    final dynamic imgBase64 = res['profileImageBase64'] ?? '';
    final dynamic imgUrl = res['profileImageUrl'] ?? '';

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
      nickname: (res['nickname'] ?? '').toString(),
      profileImageBase64: imgBase64 == null ? '' : imgBase64.toString(),
      profileImageUrl: imgUrl == null ? '' : imgUrl.toString(),
    );
  }
}
