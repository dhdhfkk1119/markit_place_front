import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/auth/register_page/widgets/register_body.dart';
import '../social_login_page/social_login_page.dart';

// 회원가입 페이지를 정의하는 위젯입니다.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SocialLoginPage()),
            );
          },
        ),
        title: const Text('회원 가입', style: TextStyle(fontFamily: "CookieRun")),
        centerTitle: false,
      ),
      body: const RegisterBody(),
    );
  }
}
