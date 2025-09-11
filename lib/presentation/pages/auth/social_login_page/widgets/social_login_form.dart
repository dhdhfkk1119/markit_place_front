import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:markit_place_front/_core/constants/size.dart';

class SocialLoginForm extends StatelessWidget {
  const SocialLoginForm({super.key});

  Widget _buildLoginButton(BuildContext context, String title,
      {String? iconAssetPath, required VoidCallback onPressed}) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildLoginButton(
          context,
          "구글 로그인",
          iconAssetPath: "assets/social/google.svg",
          onPressed: () {
            // TODO: 구글 로그인 로직 구현
            print("구글 로그인 클릭");
            Navigator.pushNamed(context, "product/list");
          },
        ),
        const SizedBox(height: small),
        _buildLoginButton(
          context,
          "네이버 로그인",
          iconAssetPath: "assets/social/naver.svg",
          onPressed: () {
            // TODO: 네이버 로그인 로직 구현
            print("네이버 로그인 클릭");
            Navigator.pushNamed(context, "product/list");
          },
        ),
        const SizedBox(height: small),
        _buildLoginButton(
          context,
          "카카오 로그인",
          iconAssetPath: "assets/social/kakao.svg",
          onPressed: () {
            // TODO: 카카오 로그인 로직 구현
            print("카카오 로그인 클릭");
            Navigator.pushNamed(context, "product/list");
          },
        ),
        const SizedBox(height: small),
        _buildLoginButton(
          context,
          "일반 회원 로그인",
          onPressed: () {
            Navigator.pushNamed(context, "/account-login");
          },
        ),
        const SizedBox(height: small),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "아직 아이디가 없으신가요?",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/terms");
              },
              child: Text(
                "회원가입",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: xSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "아이디/비밀번호가 생각나지 않으세요?",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/find-account");
              },
              child: Text(
                "계정찾기",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
