import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart'; // 상수 파일 임포트
import 'package:markit_place_front/presentation/widgets/custom_logo.dart';
import 'social_login_form.dart';

// 소셜 로그인 페이지의 본문 레이아웃을 담당하는 위젯
class SocialLoginBody extends StatelessWidget {
  const SocialLoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAF6F2), // TODO: 앱 테마 색상 시스템에 맞게 조정 고려
      // 모든 방향으로 일관된 여백을 적용
      child: Padding(
        padding: const EdgeInsets.all(large),
        // 자식 위젯들을 스크롤 가능한 목록 형태로 배치
        child: ListView(
          children: const [
            // 앱 로고 및 슬로건 표시 (커스텀 위젯)
            CustomLogo("Markit Place", "언제 어디서나 즐겁게 거래해요", "CookieRun"),
            SizedBox(height: large),
            // 다양한 소셜 로그인 옵션을 제공하는 폼 위젯
            SocialLoginForm(),
          ],
        ),
      ),
    );
  }
}
