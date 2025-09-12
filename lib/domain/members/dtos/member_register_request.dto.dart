import 'package:markit_place_front/domain/members/models/member.dart';

class MemberRegisterRequestDto {
  final String loginId;
  final String password;
  final String email;
  final bool isEmailVerified;
  final List<int> agreedTermIds;

  MemberRegisterRequestDto({
    required this.loginId,
    required this.password,
    required this.email,
    required this.isEmailVerified,
    required this.agreedTermIds,
  });

  factory MemberRegisterRequestDto.fromModel(Member model) {
    // 파라미터 타입 Member로 변경
    // Member 모델의 필드들이 nullable이므로, non-null임을 보장하거나 예외 처리가 필요할 수 있습니다.
    // 여기서는 요청 모델이므로 해당 값들이 채워져 있다고 가정합니다.
    return MemberRegisterRequestDto(
      loginId: model.loginId, // Member.loginId는 non-nullable이므로 그대로 사용
      password: model
          .password!, // Member.password는 nullable이므로 non-null 단언 또는 null 처리 필요
      email:
          model.email!, // Member.email은 nullable이므로 non-null 단언 또는 null 처리 필요
      isEmailVerified: model
          .isEmailVerified!, // Member.isEmailVerified는 nullable이므로 non-null 단언 또는 null 처리 필요
      agreedTermIds: model
          .agreedTermIds!, // Member.agreedTermIds는 nullable이므로 non-null 단언 또는 null 처리 필요
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loginId': loginId,
      'password': password,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'agreedTermIds': agreedTermIds,
    };
  }
}
