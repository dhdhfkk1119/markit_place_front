import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/_core/constants/theme.dart';

import '../../_core/constants/assets.dart'; // kAppSecondaryColor를 사용

/// 보조 기능이 중간크기의 버튼이다.
// 중복확인, 이메일인증
class CustomButtonMedium extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButtonMedium({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAppSecondaryColor, // 배경색: 연보라 (테마 상수 사용)
        foregroundColor: Colors.black, // 글자/아이콘 기본색: 검정색
        minimumSize: const Size(0, xLarge), // 버튼의 최소 크기 (높이 xLarge)
        padding: const EdgeInsets.symmetric(
            horizontal: medium, vertical: small), // 내부 패딩
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(small), // 테두리 둥글기 (CustomSubmitButton과 동일)
        ),
        textStyle: TextStyle(
          // 텍스트 스타일 직접 지정
          fontFamily: Assets.Fonts.cookieRun,
          fontSize: medium,
          color: Colors.black, // 텍스트 색상을 검정색으로 변경
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
