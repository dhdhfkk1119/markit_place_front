import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';

/// 빅버튼 아래에 들어가는 회색 텍스트 링크
// 아직 아이디가 없으세요? 회원가입
class CustomLInkGrey extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // onPressed는 null일 수 있음

  const CustomLInkGrey({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: small),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black54,
            fontFamily: "CookieRun",
          ),
        ),
      ),
    );
  }
}
