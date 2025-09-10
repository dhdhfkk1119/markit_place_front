import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/auth/register_page/widgets/register_body.dart';
// import '../social_login_page/social_login_page.dart'; // 이미 이전 단계에서 제거됨

// 회원가입 페이지 정의 위젯
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드 표시 시 UI 자동 조절 활성화
      appBar: AppBar(
        // AppBar 좌측 아이콘 버튼 (닫기)
        leading: IconButton(
          icon: const Icon(Icons.close), // 닫기 아이콘
          // 버튼 클릭 시 소셜 로그인 페이지로 이동 (교체, 명명된 라우트 사용)
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/social-login');
          },
        ),
        // AppBar 제목
        title: const Text('회원 가입', style: TextStyle(fontFamily: "CookieRun")),
        centerTitle: false, // 제목 왼쪽 정렬
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
      // 페이지 본문 내용
      body: const RegisterBody(),
    );
  }
}
