class ProfileUpdateRequestDto {
  final String? name;
  final String? profileImage; // API 명세에 따라 필드명 'profileImage' 사용 (프로필 사진 URL)

  ProfileUpdateRequestDto({
    this.name,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) {
      data['name'] = name;
    }
    if (profileImage != null) {
      data['profileImage'] = profileImage;
    }
    return data;
  }
}
