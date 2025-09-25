class ProfileUpdateRequestDto {
  final String? name;
  final String? profileImage; // 이 필드가 Base64 인코딩된 이미지 문자열을 받음
  // final File? profileImageFile; // 이 필드는 제거 (FormData 대신 JSON으로 Base64 전송)

  ProfileUpdateRequestDto({
    this.name,
    this.profileImage, // Base64 문자열을 받는 필드
    // this.profileImageFile, // 생성자에서 제거
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null && name!.isNotEmpty) {
      // 이름이 비어있지 않은 경우에만 포함 (선택적)
      data['name'] = name;
    }
    if (profileImage != null && profileImage!.isNotEmpty) {
      // 프로필 이미지가 비어있지 않은 경우에만 포함
      data['profileImage'] = profileImage;
    }
    // profileImageFile 관련 로직은 모두 제거
    return data;
  }

  ProfileUpdateRequestDto copyWith({
    String? name,
    String? profileImage,
  }) {
    return ProfileUpdateRequestDto(
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
