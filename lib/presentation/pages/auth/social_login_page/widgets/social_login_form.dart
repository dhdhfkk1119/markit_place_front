import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:markit_place_front/_core/constants/assets.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart';
import 'package:markit_place_front/presentation/widgets/custom_link_grey.dart';
// UserRepository를 사용하기 위한 임포트 추가
import 'package:markit_place_front/domain/repositories/auth_repository/user_repository.dart';

class SocialLoginForm extends StatelessWidget {
  const SocialLoginForm({super.key});

  Widget _buildSocialIcon(BuildContext context,
      {required String iconAssetPath,
      required VoidCallback onPressed,
      double iconSize = 48.0}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(iconSize / 2 + xSmall),
      child: Padding(
        padding: const EdgeInsets.all(xSmall),
        child: SvgPicture.asset(
          iconAssetPath,
          height: iconSize,
          width: iconSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: medium),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
              context,
              iconAssetPath: Assets.Svgs.google,
              onPressed: () {
                // TODO: 구글 로그인 로직 구현
                print("구글 로그인 클릭");
                Navigator.pushNamed(context, "product/list");
              },
            ),
            const SizedBox(width: large),
            _buildSocialIcon(
              context,
              iconAssetPath: Assets.Svgs.naver,
              onPressed: () {
                // TODO: 네이버 로그인 로직 구현 (기능 유지)
                print("네이버 로그인 클릭");
                UserRepository().signInWithNaver();
              },
            ),
            const SizedBox(width: large),
            _buildSocialIcon(
              context,
              iconAssetPath: Assets.Svgs.kakao,
              onPressed: () {
                // TODO: 카카오 로그인 로직 구현
                print("카카오 로그인 클릭");
                Navigator.pushNamed(context, "product/list");
              },
            ),
          ],
        ),
        const SizedBox(height: medium), // 소셜 아이콘과 일반이메일 로그인 버튼 사이 간격
        CustomButtonLarge(
          text: "일반이메일 로그인",
          onPressed: () {
            // TODO: 일반 이메일 로그인 로직 구현 또는 페이지 이동
            print("일반이메일 로그인 클릭됨");
            // Navigator.pushNamed(context, "/email-login"); // 예시 경로
          },
        ),
        const SizedBox(height: small), // 일반이메일 로그인 버튼과 "아이디로 로그인하기" 링크 사이 간격
        Center(
          // "아이디로 로그인하기" 링크 추가
          child: CustomLInkGrey(
            text: '아이디로 로그인하기',
            onPressed: () {
              Navigator.pushNamed(context, "/account-login");
            },
          ),
        ),
        const SizedBox(height: small), // "아이디로 로그인하기" 링크와 "회원가입" 링크 사이 간격
        Center(
          child: CustomLInkGrey(
            text: '아직 아이디가 없으신가요? 회원가입',
            onPressed: () {
              Navigator.pushNamed(context, "/terms");
            },
          ),
        ),
        const SizedBox(height: xSmall),
        Center(
          child: CustomLInkGrey(
            text: '아이디/비밀번호가 생각나지 않으세요? 계정찾기',
            onPressed: () {
              Navigator.pushNamed(context, "/find-account");
            },
          ),
        ),
      ],
    );
  }
}
