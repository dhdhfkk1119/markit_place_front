import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart'; // SVG 이미지를 사용하기 위한 임포트
import 'package:markit_place_front/_core/constants/size.dart'; // 상수 파일 임포트
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/domain/repositories/auth_repository/user_repository.dart';
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
        style: TextStyle(
          // 테마의 button 텍스트 스타일 또는 onPrimary 색상 등 사용 고려
          color: theme.colorScheme.onSurface, // 테마의 surface 위의 텍스트 색상 사용 (예시)
          fontSize: medium, // 폰트 크기 (medium 상수 사용)
          fontFamily: "CookieRun", // 앱 전체 폰트 테마 적용 고려
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return InkWell(
      onTap: onPressed, // 버튼 클릭 시 실행될 콜백 함수
      child: Container(
        width: double.infinity, // 버튼 너비를 최대로 확장
        height: xLarge, // 버튼 높이 수정: xxLarge -> xLarge
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // 테마의 surface 색상 사용 (예시)
          borderRadius:
              BorderRadius.circular(large), // 버튼 모서리 둥글게 (large 상수 사용)
          boxShadow: [
            // 은은한 그림자 효과 추가 (예시)
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
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
          },
        ),
        const SizedBox(height: small), // 버튼 사이 간격 수정: medium -> small

        // 네이버 로그인 버튼
        _buildLoginButton(
          context,
          "네이버 로그인",
          iconAssetPath: "assets/social/naver.svg", // 네이버 로고 SVG 경로
          onPressed: () {
            // TODO: 네이버 로그인 로직 구현
            print("네이버 로그인 클릭");
            UserRepository().signInWithNaver();
          },
        ),
        const SizedBox(height: small), // 버튼 사이 간격 수정: medium -> small

        // 카카오 로그인 버튼
        _buildLoginButton(
          context,
          "카카오 로그인",
          iconAssetPath: "assets/social/kakao.svg", // 카카오 로고 SVG 경로
          onPressed: () {
            // TODO: 카카오 로그인 로직 구현
            print("카카오 로그인 클릭");
          },
        ),
        const SizedBox(height: small), // 버튼 사이 간격 수정: medium -> small

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
        const SizedBox(height: small), // 버튼과 회원가입 링크 사이 간격 수정: medium -> small

        // 회원가입 안내 및 링크
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
          children: [
            Text(
              "아직 아이디가 없으신가요?",
              style: TextStyle(
                  fontSize: medium,
                  fontFamily: "CookieRun",
                  color: theme.colorScheme.onSurface), // 테마 색상 적용
            ),
            TextButton(
              onPressed: () {
                // 약관 동의 페이지로 이동 (명명된 라우트 사용)
                Navigator.pushNamed(context, "/terms");
              },
              child: Text(
                "회원가입",
                style: TextStyle(
                    color: theme.colorScheme.primary, // 테마의 primary 색상 사용
                    fontSize: medium,
                    fontFamily: "CookieRun"),
              ),
            ),
          ],
        ),
        const SizedBox(height: xSmall), // 링크 사이 간격 수정: small -> xSmall

        // 아이디/비밀번호 찾기 안내 및 링크 (새로 추가된 부분)
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
          children: [
            Text(
              "아이디/비밀번호가 생각나지 않으세요?",
              style: TextStyle(
                  fontSize: medium,
                  fontFamily: "CookieRun",
                  color: theme.colorScheme.onSurface), // 테마 색상 적용
            ),
            TextButton(
              onPressed: () {
                // 계정 찾기 페이지로 이동 (명명된 라우트 사용)
                Navigator.pushNamed(context, "/find-account");
              },
              child: Text(
                "계정찾기",
                style: TextStyle(
                    color: theme.colorScheme.primary, // 테마의 primary 색상 사용
                    fontSize: medium,
                    fontFamily: "CookieRun"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
