import 'package:flutter/material.dart';
import 'account_login_form.dart';

// 일반 계정 로그인 페이지의 주요 레이아웃을 담당하는 위젯.
class AccounLoginBody extends StatelessWidget {
  const AccounLoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: AccounLoginForm(),
    );
  }
}
