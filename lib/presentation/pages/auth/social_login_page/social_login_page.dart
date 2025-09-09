import 'package:flutter/material.dart';
import 'widgets/social_login_body.dart';

// 소셜 로그인 페이지를 정의하는 위젯
class SocialLoginPage extends StatelessWidget {
  const SocialLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드 표시 시 UI 자동 조절 비활성화
      body: SocialLoginBody(), // 소셜 로그인 페이지 본문
    );
  }
}
