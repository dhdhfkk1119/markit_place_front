import 'package:flutter/material.dart';
import '../../../../_core/constants/assets.dart';
import 'widgets/account_login_body.dart';

// 일반 계정 로그인 페이지 정의 위젯
class AccountLoginPage extends StatelessWidget {
  const AccountLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar 제목
        title:
            Text('로그인', style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
        // AppBar 하단 구분선 (Divider 위젯으로 변경)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            color: Colors.grey.shade300,
            height: 1.0,
            thickness: 1.0,
          ),
        ),
        // AppBar 좌측 뒤로가기 버튼
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.of(context).pop(); // 이전 화면 이동
          },
        ),
      ),
      // 페이지 본문
      body: const AccountLoginBody(), // 오타 수정: AccountLoginBody
    );
  }
}
