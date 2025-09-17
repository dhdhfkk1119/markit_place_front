
class ProfileResponseDto {
  final int mannerScore;
  final int retransactionRate;
  final String nickname;
  final String userCode;


  ProfileResponseDto({
    required this.mannerScore,
    required this.retransactionRate,
    required this.nickname,
    required this.userCode,
  });


  factory ProfileResponseDto.fromJson(Map<String, dynamic> json) {
    return ProfileResponseDto(
      mannerScore: json['mannerScore'] as int? ?? 0,
      retransactionRate: json['retransactionRate'] as int? ?? 0,
      nickname: json['nickname'] as String? ?? '',
      userCode: json['userCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mannerScore': mannerScore,
      'retransactionRate': retransactionRate,
      'nickname': nickname,
      'userCode': userCode,
    };
  }
}