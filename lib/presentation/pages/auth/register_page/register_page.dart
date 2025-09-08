import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/auth/login_page/login_page.dart'; // LoginPage 임포트 추가
import 'package:markit_place_front/presentation/pages/auth/register_page/widgets/register_body.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
        title: Text('회원 가입'), // 제목 유지
        centerTitle: false, // 중앙 정렬 해제하여 왼쪽으로 이동
      ),
      body: RegisterBody(),
    );
  }
}
