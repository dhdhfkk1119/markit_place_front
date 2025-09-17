class FindIdMaskedResponseDto {
  final String maskedLoginId;

  FindIdMaskedResponseDto({required this.maskedLoginId});

  factory FindIdMaskedResponseDto.fromJson(Map<String, dynamic> json) {
    return FindIdMaskedResponseDto(
      maskedLoginId: json['maskedLoginId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maskedLoginId': maskedLoginId,
    };
  }
}
