import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'account_login_form.dart';

// 일반 계정 로그인 페이지의 본문 레이아웃을 담당하는 위젯
class AccountLoginBody extends StatelessWidget {
  const AccountLoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    // 페이지 전체에 일관된 여백을 적용
    return const Padding(
      padding: EdgeInsets.all(medium),
      // 계정 로그인 폼 위젯을 자식으로 가짐
      child: AccountLoginForm(),
    );
  }
}
