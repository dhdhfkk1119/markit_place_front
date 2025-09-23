// PATCH /api/members/me 요청/응답 DTO

// 프로필 수정 요청 DTO
class ProfileEditRequestDto {
  final String? name;
  final String? profileImage;
  ProfileEditRequestDto({this.name, this.profileImage});

  // DTO를 JSON으로 변환
  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (profileImage != null) 'profileImage': profileImage,
      };
}

// 프로필 수정 응답 DTO
class ProfileEditResponseDto {
  final int id;
  final String name;
  final String status;
  final String profileImageBase64;

  ProfileEditResponseDto({
    required this.id,
    required this.name,
    required this.status,
    required this.profileImageBase64,
  });

  // JSON 응답을 DTO로 변환
  factory ProfileEditResponseDto.fromJson(Map<String, dynamic> json) {
    final res = json['response'] ?? {};
    return ProfileEditResponseDto(
      id: res['id'],
      name: res['name'],
      status: res['status'],
      profileImageBase64: res['profileImageBase64'],
    );
  }
}
