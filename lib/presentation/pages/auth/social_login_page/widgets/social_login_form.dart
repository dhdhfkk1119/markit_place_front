import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:flutter_svg/svg.dart';
import 'package:markit_place_front/presentation/pages/auth/account_login_page/account_login_page.dart';

// 소셜 로그인 및 기타 인증 관련 액션 버튼 포함 폼 위젯
class SocialLoginForm extends StatelessWidget {
  const SocialLoginForm({super.key});

  // 소셜 로그인 폼 UI 구조 정의
  @override
  Widget build(BuildContext context) {
    // 여러 UI 요소 세로 배열
    return Column(
      children: [
        // "구글 로그인" 버튼 표시
        getInkWell("구글 로그인", context),
        const SizedBox(
          height: middle,
        ),
        // "네이버 로그인" 버튼 표시
        getInkWell("네이버 로그인", context),
        const SizedBox(
          height: middle,
        ),
        // "카카오 로그인" 버튼 표시
        getInkWell("카카오 로그인", context),
        const SizedBox(
          height: middle,
        ),
        // "일반 회원 로그인" 버튼 표시
        getInkWell("일반 회원 로그인", context),
        const SizedBox(
          height: middle,
        ),
        // 회원가입 안내 문구 및 링크 화면 중앙 배치
        Center(
            child: Row(
          // 문구와 버튼 가로 배치
          mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
          children: [
// 사용자 회원가입 여부 확인 텍스트
            const Text(
              "아직 아이디가 없으신가요?",
              style: TextStyle(fontSize: middle, fontFamily: "CookieRun"),
            ),
            // "회원가입" 텍스트 버튼
            TextButton(
                onPressed: () {
                  // 버튼 클릭 시 회원가입 페이지 이동
                  Navigator.pushNamed(context, "/register");
                },
                child: const Text(
                  "회원가입",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: middle,
                      fontFamily: "CookieRun"),
                ))
          ],
        )),
      ],
    );
  }

  // 제목(title) 기반 아이콘 포함, 클릭 가능 로그인 버튼 위젯 생성
  // 버튼 클릭 시 페이지 이동 로직 포함
  Widget getInkWell(String title, BuildContext context) {
    String? iconAssetPath; // SVG 아이콘 에셋 경로 저장 변수

    // 버튼 제목 기반 아이콘 에셋 경로 결정
    if (title == "구글 로그인") {
      iconAssetPath = "assets/social/google.svg";
    } else if (title == "네이버 로그인") {
      iconAssetPath = "assets/social/naver.svg";
    } else if (title == "카카오 로그인") {
      iconAssetPath = "assets/social/kakao.svg";
    }

    // 버튼 내부 아이콘 및 텍스트 포함 위젯 리스트
    List<Widget> rowChildren = [];

    // 아이콘 경로 설정 시, 아이콘 위젯 및 우측 여백 리스트 추가
    if (iconAssetPath != null) {
      // SVG 이미지 표시 위젯
      rowChildren.add(
          SvgPicture.asset(iconAssetPath, height: quarter, width: quarter));
      rowChildren.add(const SizedBox(width: small));
    }

    // 버튼 표시 주 텍스트 리스트 추가
    rowChildren.add(
      Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: middle,
          fontFamily: "CookieRun",
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // 클릭 가능 영역 제공 위젯
    return InkWell(
      onTap: () {
        // 버튼 클릭 시 실행될 네비게이션 로직
        if (title == "구글 로그인" || title == "네이버 로그인" || title == "카카오 로그인") {
          // 소셜 로그인 선택 시 제품 목록 페이지 이동
          Navigator.pushNamed(context, "product/list");
        } else if (title == "일반 회원 로그인") {
          // 일반 계정 로그인 선택 시 해당 로그인 페이지 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AccountLoginPage()),
          );
        }
      },
      // 버튼 시각적 형태 정의 컨테이너
      child: Container(
        width: double.infinity, // 컨테이너 너비 최대 확장
        height: half, // 컨테이너 높이 half로 고정
        // 컨테이너 배경색, 모서리 모양 등 장식 관련 속성 설정
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(quarter),
        ),
        // 컨테이너 내부 자식 위젯(아이콘, 텍스트) 가로 배치 및 중앙 정렬
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowChildren,
        ),
      ),
    );
  }
}
