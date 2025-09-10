import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart'; // SVG 이미지를 사용하기 위한 임포트
import 'package:markit_place_front/_core/constants/size.dart'; // 상수 파일 임포트
// import 'package:markit_place_front/presentation/pages/auth/account_login_page/account_login_page.dart'; // 명명된 라우트 사용으로 직접 임포트 불필요

// 소셜 로그인 버튼들과 일반 로그인/회원가입 네비게이션을 제공하는 StatelessWidget
class SocialLoginForm extends StatelessWidget {
  const SocialLoginForm({super.key});

  // 각 로그인 옵션에 대한 버튼을 생성하는 내부 헬퍼 함수
  Widget _buildLoginButton(BuildContext context, String title,
      {String? iconAssetPath, required VoidCallback onPressed}) {
    final theme = Theme.of(context); // 현재 테마 접근

    List<Widget> buttonChildren = []; // 버튼 내부에 표시될 위젯 목록

    if (iconAssetPath != null) {
      buttonChildren.add(SvgPicture.asset(iconAssetPath,
          height: large, width: large)); // SVG 아이콘 (large 상수 사용)
      buttonChildren
          .add(const SizedBox(width: small)); // 아이콘과 텍스트 사이 간격 (small 상수 사용)
    }

    buttonChildren.add(
      Text(
        title,
        style: const TextStyle(
          // TODO: 테마의 button 텍스트 스타일 또는 onPrimary 색상 등 사용 고려
          color: Colors.black, // 현재는 검정색 고정
          fontSize: medium, // 폰트 크기 (medium 상수 사용)
          fontFamily: "CookieRun", // TODO: 앱 전체 폰트 테마 적용 고려
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return InkWell(
      onTap: onPressed, // 버튼 클릭 시 실행될 콜백 함수
      child: Container(
        width: double.infinity, // 버튼 너비를 최대로 확장
        height: xxLarge, // 버튼 높이 (xxLarge 상수 사용)
        decoration: BoxDecoration(
          // TODO: 테마의 surface 또는 cardColor 등 사용 고려
          color: Colors.white, // 현재는 흰색 배경 고정
          borderRadius:
              BorderRadius.circular(large), // 버튼 모서리 둥글게 (large 상수 사용)
          // TODO: 그림자 효과(elevation) 등 테마 스타일 적용 고려
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // 내부 요소들 중앙 정렬
          children: buttonChildren,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 현재 테마 접근

    return Column(
      children: [
        // 구글 로그인 버튼
        _buildLoginButton(
          context,
          "구글 로그인",
          iconAssetPath: "assets/social/google.svg", // 구글 로고 SVG 경로
          onPressed: () {
            // TODO: 구글 로그인 로직 구현
            print("구글 로그인 클릭");
            Navigator.pushNamed(context, "product/list"); // 임시: 상품 목록으로 이동
          },
        ),
        const SizedBox(height: medium), // 버튼 사이 간격

        // 네이버 로그인 버튼
        _buildLoginButton(
          context,
          "네이버 로그인",
          iconAssetPath: "assets/social/naver.svg", // 네이버 로고 SVG 경로
          onPressed: () {
            // TODO: 네이버 로그인 로직 구현
            print("네이버 로그인 클릭");
            Navigator.pushNamed(context, "product/list"); // 임시: 상품 목록으로 이동
          },
        ),
        const SizedBox(height: medium), // 버튼 사이 간격

        // 카카오 로그인 버튼
        _buildLoginButton(
          context,
          "카카오 로그인",
          iconAssetPath: "assets/social/kakao.svg", // 카카오 로고 SVG 경로
          onPressed: () {
            // TODO: 카카오 로그인 로직 구현
            print("카카오 로그인 클릭");
            Navigator.pushNamed(context, "product/list"); // 임시: 상품 목록으로 이동
          },
        ),
        const SizedBox(height: medium), // 버튼 사이 간격

        // 일반 회원 로그인 버튼
        _buildLoginButton(
          context,
          "일반 회원 로그인",
          // iconAssetPath는 선택 사항이므로 여기서는 제공하지 않음
          onPressed: () {
            // 계정 로그인 페이지로 이동 (명명된 라우트 사용)
            Navigator.pushNamed(context, "/account-login");
          },
        ),
        const SizedBox(height: medium), // 버튼과 회원가입 링크 사이 간격

        // 회원가입 안내 및 링크
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
          children: [
            const Text(
              "아직 아이디가 없으신가요?",
              style: TextStyle(
                  fontSize: medium, fontFamily: "CookieRun"), // TODO: 테마 폰트
            ),
            TextButton(
              onPressed: () {
                // 약관 동의 페이지로 이동 (명명된 라우트 사용)
                Navigator.pushNamed(context, "/terms");
              },
              child: const Text(
                "회원가입",
                style: TextStyle(
                    // TODO: 테마의 primary 또는 error 색상 등 의미있는 색상 사용 고려
                    color: Colors.redAccent, // 현재는 빨간 계열 강조색 고정
                    fontSize: medium,
                    fontFamily: "CookieRun"), // TODO: 테마 폰트
              ),
            ),
          ],
        ),
      ],
    );
  }
}
