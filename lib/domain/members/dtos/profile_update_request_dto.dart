class ProfileUpdateRequestDto {
  final String? name;
  final String? profileImage;

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
