import 'package:flutter/material.dart';
import 'find_id_form.dart';
import 'reset_password_form.dart';

// FindAccountPage의 본문 레이아웃 (TabBarView) 담당 위젯
class FindAccountBody extends StatelessWidget {
  const FindAccountBody({super.key});

  @override
  Widget build(BuildContext context) {
    // TabBarView는 DefaultTabController가 상위에 존재해야 제대로 동작합니다.
    // FindAccountPage에서 DefaultTabController로 감싸져 있으므로 여기서는 바로 사용합니다.
    return const TabBarView(
      children: [
        FindIdForm(), // 아이디 찾기 폼 위젯
        ResetPasswordForm(), // 비밀번호 초기화 폼 위젯
      ],
    );
  }
}
