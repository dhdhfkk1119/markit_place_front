import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:flutter_svg/svg.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        getInkWell("네이버 로그인", context),
        const SizedBox(
          height: twenGap,
        ),
        getInkWell("구글 로그인", context),
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
    return InkWell(
      onTap: () {
        if (title == "네이버 로그인") {
          Navigator.pushNamed(context, "product/list");
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
          children: [
            SvgPicture.asset("assets/social/google.svg"),
            const SizedBox(width: 8),
            Text(
              title, // $title → 그냥 title로
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: "CookieRun",
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
