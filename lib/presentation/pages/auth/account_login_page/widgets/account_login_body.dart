import 'package:flutter/material.dart';
import 'account_login_form.dart';

class AccounLoginBody extends StatelessWidget {
  const AccounLoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0), // 전체적인 패딩
      child: AccounLoginForm(),
    );
  }
}
