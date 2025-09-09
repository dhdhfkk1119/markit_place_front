import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/widgets/custom_logo.dart';
import 'social_login_form.dart';

// 소셜 로그인 페이지의 주요 레이아웃을 담당하는 위젯입니다.
class SocialLoginBody extends StatelessWidget {
  const SocialLoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    // 페이지 전체를 감싸는 컨테이너로, 배경색을 지정합니다.
    return Container(
      color: const Color(0xFFFAF6F2), // 연한 배경색을 설정합니다.
      // 컨테이너 내부에 패딩을 적용합니다.
      child: Padding(
        padding: const EdgeInsets.all(24.0), // 모든 방향에 24.0의 패딩을 적용합니다.
        // 스크롤 가능한 목록 형태로 자식 위젯들을 배열합니다.
        child: ListView(
          // ListView 내부에 표시될 위젯들의 목록입니다.
          children: const [
            // 앱의 로고와 슬로건을 표시하는 커스텀 위젯입니다.
            CustomLogo("Markit Place", "언제 어디서나 즐겁게 거래해요", "CookieRun"),
            // 다양한 소셜 로그인 옵션을 제공하는 폼 위젯입니다.
            SocialLoginForm()
          ],
        ),
      ),
    );
  }
}
