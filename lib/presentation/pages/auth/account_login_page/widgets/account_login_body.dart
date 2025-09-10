import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'account_login_form.dart';

// 일반 계정 로그인 페이지 주요 레이아웃 위젯
class AccounLoginBody extends StatelessWidget {
  const AccounLoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    // 전체 패딩 적용
    return const Padding(
      padding: EdgeInsets.all(middle),
      // 계정 로그인 폼
      child: AccounLoginForm(),
    );
  }
}
