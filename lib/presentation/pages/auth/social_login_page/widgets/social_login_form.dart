import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:flutter_svg/svg.dart';
import 'package:markit_place_front/presentation/pages/auth/account_login_page/account_login_page.dart';

class SocialLoginForm extends StatelessWidget {
  const SocialLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        getInkWell("구글 로그인", context),
        const SizedBox(
          height: twenGap,
        ),
        getInkWell("네이버 로그인", context),
        const SizedBox(
          height: twenGap,
        ),
        getInkWell("카카오 로그인", context),
        const SizedBox(
          height: twenGap,
        ),
        getInkWell("일반 회원 로그인", context),
        const SizedBox(
          height: twenGap,
        ),
        Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "아직 아이디가 없으신가요?",
              style: TextStyle(fontSize: 16, fontFamily: "CookieRun"),
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/register");
                },
                child: const Text(
                  "회원가입",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontFamily: "CookieRun"),
                ))
          ],
        )),
      ],
    );
  }

  getInkWell(String title, BuildContext context) {
    String? iconAssetPath;
    if (title == "구글 로그인") {
      iconAssetPath = "assets/social/google.svg";
    } else if (title == "네이버 로그인") {
      iconAssetPath = "assets/social/naver.svg";
    } else if (title == "카카오 로그인") {
      iconAssetPath = "assets/social/kakao.svg";
    }

    List<Widget> rowChildren = [];

    if (iconAssetPath != null) {
      rowChildren.add(SvgPicture.asset(iconAssetPath, height: 24, width: 24));
      rowChildren.add(const SizedBox(width: 8));
    }

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

    return InkWell(
      onTap: () {
        if (title == "구글 로그인" || title == "네이버 로그인" || title == "카카오 로그인") {
          Navigator.pushNamed(context, "product/list");
        } else if (title == "일반 회원 로그인") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AccountLoginPage()),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowChildren,
        ),
      ),
    );
  }
}
