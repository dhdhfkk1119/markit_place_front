import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/widgets/custom_logo.dart';
import 'social_login_form.dart';

// 소셜 로그인 페이지의 주요 레이아웃을 담당하는 위젯
class SocialLoginBody extends StatelessWidget {
  const SocialLoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAF6F2), // 배경색 설정
      child: Padding(
        padding: const EdgeInsets.all(24.0), // 전체 패딩
        child: ListView(
          // 스크롤 가능한 콘텐츠 영역
          children: [
            const CustomLogo(
                "Markit Place", "언제 어디서나 즐겁게 거래해요", "CookieRun"), // 앱 로고
            SocialLoginForm() // 소셜 로그인 폼
          ],
        ),
      ),
    );
  }
}
