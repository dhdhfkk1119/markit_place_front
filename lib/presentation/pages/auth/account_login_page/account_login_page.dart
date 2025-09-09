import 'package:flutter/material.dart';
import 'widgets/account_login_body.dart';

// 일반 계정 로그인 페이지를 정의하는 위젯.
class AccountLoginPage extends StatelessWidget {
  const AccountLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인', style: TextStyle(fontFamily: "CookieRun")),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: const AccounLoginBody(), // 계정 로그인 페이지 본문
    );
  }
}
