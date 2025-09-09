import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:flutter_svg/svg.dart';
import 'package:markit_place_front/presentation/pages/auth/account_login_page/account_login_page.dart';

// 소셜 로그인 및 기타 인증 관련 액션 버튼들을 포함하는 폼 위젯
class SocialLoginForm extends StatelessWidget {
  const SocialLoginForm({super.key});

  // 소셜 로그인 폼의 UI 구조를 정의합니다.
  @override
  Widget build(BuildContext context) {
    // 여러 UI 요소들을 세로로 배열합니다.
    return Column(
      children: [
        // "구글 로그인" 버튼을 표시합니다.
        getInkWell("구글 로그인", context),
        // UI 요소들 사이의 수직 여백을 제공합니다.
        const SizedBox(
          height: twenGap,
        ),
        // "네이버 로그인" 버튼을 표시합니다.
        getInkWell("네이버 로그인", context),
        // UI 요소들 사이의 수직 여백을 제공합니다.
        const SizedBox(
          height: twenGap,
        ),
        // "카카오 로그인" 버튼을 표시합니다.
        getInkWell("카카오 로그인", context),
        // UI 요소들 사이의 수직 여백을 제공합니다.
        const SizedBox(
          height: twenGap,
        ),
        // "일반 회원 로그인" 버튼을 표시합니다.
        getInkWell("일반 회원 로그인", context),
        // UI 요소들 사이의 수직 여백을 제공합니다.
        const SizedBox(
          height: twenGap,
        ),
        // 회원가입 안내 문구 및 링크를 화면 중앙에 배치합니다.
        Center(
            child: Row(
          // 문구와 버튼을 가로로 나란히 배치합니다.
          mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙에 정렬합니다.
          children: [
            // 사용자에게 회원가입 여부를 묻는 텍스트입니다.
            const Text(
              "아직 아이디가 없으신가요?",
              style: const TextStyle(fontSize: 16, fontFamily: "CookieRun"),
            ),
            // "회원가입" 텍스트 버튼입니다.
            TextButton(
                onPressed: () {
                  // 버튼 클릭 시 회원가입 페이지로 이동합니다.
                  Navigator.pushNamed(context, "/register");
                },
                child: const Text(
                  "회원가입",
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontFamily: "CookieRun"),
                ))
          ],
        )),
      ],
    );
  }

  // 제공된 제목(title)에 따라 적절한 아이콘과 함께 클릭 가능한 로그인 버튼 위젯을 생성합니다.
  // 버튼 클릭 시 적절한 페이지로 이동하는 로직을 포함합니다.
  Widget getInkWell(String title, BuildContext context) {
    String? iconAssetPath; // SVG 아이콘 에셋의 경로를 저장할 변수입니다.

    // 버튼의 제목에 따라 사용할 아이콘 에셋의 경로를 결정합니다.
    if (title == "구글 로그인") {
      iconAssetPath = "assets/social/google.svg";
    } else if (title == "네이버 로그인") {
      iconAssetPath = "assets/social/naver.svg";
    } else if (title == "카카오 로그인") {
      iconAssetPath = "assets/social/kakao.svg";
    }

    // 버튼 내부에 아이콘과 텍스트를 담을 위젯 리스트입니다.
    List<Widget> rowChildren = [];

    // 아이콘 경로가 설정되어 있다면, 아이콘 위젯과 그 오른쪽 여백을 리스트에 추가합니다.
    if (iconAssetPath != null) {
      // SVG 이미지를 표시하는 위젯입니다.
      rowChildren.add(SvgPicture.asset(iconAssetPath, height: 24, width: 24));
      // 아이콘과 텍스트 사이의 가로 여백입니다.
      rowChildren.add(const SizedBox(width: 8));
    }

    // 버튼에 표시될 주 텍스트를 리스트에 추가합니다.
    rowChildren.add(
      Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: "CookieRun",
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // 클릭 가능한 영역을 제공하는 위젯입니다.
    return InkWell(
      onTap: () {
        // 버튼이 눌렸을 때 실행될 네비게이션 로직입니다.
        if (title == "구글 로그인" || title == "네이버 로그인" || title == "카카오 로그인") {
          // 소셜 로그인 선택 시 제품 목록 페이지로 이동합니다.
          Navigator.pushNamed(context, "product/list");
        } else if (title == "일반 회원 로그인") {
          // 일반 계정 로그인 선택 시 해당 로그인 페이지로 이동합니다.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AccountLoginPage()),
          );
        }
      },
      // 버튼의 시각적 형태를 정의하는 컨테이너입니다.
      child: Container(
        width: double.infinity, // 컨테이너의 너비를 최대로 확장합니다.
        height: 50, // 컨테이너의 높이를 50으로 고정합니다.
        // 컨테이너의 배경색, 모서리 모양 등 장식 관련 속성을 설정합니다.
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        // 컨테이너 내부의 자식 위젯(아이콘, 텍스트)들을 가로로 배치하고 중앙 정렬합니다.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowChildren,
        ),
      ),
    );
  }
}
