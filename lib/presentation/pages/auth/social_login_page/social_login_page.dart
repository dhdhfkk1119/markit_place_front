import 'package:flutter/material.dart';
import '../../../../_core/constants/assets.dart';
import 'widgets/social_login_body.dart';

// 소셜 로그인 페이지를 정의하는 위젯
class SocialLoginPage extends StatelessWidget {
  const SocialLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // const 제거
      resizeToAvoidBottomInset: false, // 키보드 표시 시 UI 자동 조절 비활성화
      appBar: AppBar(
        title: const Text('로그인', style: TextStyle(fontFamily: Fonts.cookieRun)),
        centerTitle: true, // 제목 중앙 정렬 (다른 페이지들과 통일성을 위해 고려)
        automaticallyImplyLeading: false, // 뒤로가기 버튼 자동 생성 방지 (홈페이지이므로)
        // AppBar 하단 구분선 추가
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            color: Colors.grey.shade300,
            height: 1.0,
            thickness: 1.0,
          ),
        ),
      ),
      body: const SocialLoginBody(), // 소셜 로그인 페이지 본문
    );
  }
}
