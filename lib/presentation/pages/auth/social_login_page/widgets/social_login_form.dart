import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart';
import 'package:markit_place_front/presentation/widgets/custom_link_grey.dart'; // CustomButtonLarge 임포트

class SocialLoginForm extends StatelessWidget {
  const SocialLoginForm({super.key});

  // 호버 기능이 없는 _buildSocialIcon 헬퍼 메서드 다시 추가
  Widget _buildSocialIcon(BuildContext context,
      {required String iconAssetPath,
      required VoidCallback onPressed,
      double iconSize = 48.0}) {
    // 아이콘 크기 48.0 유지
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

  // Helper method for the full-width login button with background (e.g., "일반 회원 로그인")
  // 이 메서드는 CustomButtonLarge로 대체되었으므로 주석 처리 또는 삭제 가능
  /*
  Widget _buildLoginButton(BuildContext context, String title,
      {String? iconAssetPath, // "일반 회원 로그인"의 경우 null
      required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    List<Widget> buttonChildren = [];

    if (iconAssetPath != null) {
      buttonChildren
          .add(SvgPicture.asset(iconAssetPath, height: large, width: large));
      buttonChildren.add(const SizedBox(width: small));
    }

    buttonChildren.add(
      Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(large),
      child: Container(
        width: double.infinity,
        height: xLarge,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(large),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttonChildren,
        ),
      ),
    );
  }
  */

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
              iconAssetPath: "assets/social/google.svg",
              onPressed: () {
                // TODO: 구글 로그인 로직 구현
                print("구글 로그인 클릭");
                Navigator.pushNamed(context, "product/list");
              },
            ),
            const SizedBox(width: large),
            _buildSocialIcon(
              context,
              iconAssetPath: "assets/social/naver.svg",
              onPressed: () {
                // TODO: 네이버 로그인 로직 구현
                print("네이버 로그인 클릭");
                Navigator.pushNamed(context, "product/list");
              },
            ),
            const SizedBox(width: large),
            _buildSocialIcon(
              context,
              iconAssetPath: "assets/social/kakao.svg",
              onPressed: () {
                // TODO: 카카오 로그인 로직 구현
                print("카카오 로그인 클릭");
                Navigator.pushNamed(context, "product/list");
              },
            ),
          ],
        ),
        const SizedBox(height: medium), // 소셜 아이콘과 일반 로그인 버튼 사이 간격
        CustomButtonLarge(
          // CustomButtonLarge로 변경
          text: "일반 회원 로그인",
          onPressed: () {
            Navigator.pushNamed(context, "/account-login");
          },
        ),
        const SizedBox(height: small), // 일반 로그인 버튼과 "회원가입" 링크 사이 간격
        Center(
          child: CustomLInkGrey(
            // custom_link_grey.dart 에서 StyledLinkTextButton으로 변경됨
            text: '아직 아이디가 없으신가요? 회원가입',
            onPressed: () {
              Navigator.pushNamed(context, "/terms");
            },
          ),
        ),
        const SizedBox(height: xSmall),
        Center(
          child: CustomLInkGrey(
            // custom_link_grey.dart 에서 StyledLinkTextButton으로 변경됨
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
