import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart'; // size.dart 임포트

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final TextStyle? textStyle;
  final bool isLoading; // 로딩 상태를 위한 파라미터 추가

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.textStyle,
    this.isLoading = false, // 기본값은 false
  });

  @override
  Widget build(BuildContext context) {
    // 기본 스타일 (account_login_form.dart 스타일 기반)
    final ButtonStyle defaultStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFC8BFE7), // 연한 보라색 배경
      minimumSize: const Size(double.infinity, xxLarge), // 너비 꽉 채우고, 높이 xxLarge
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(small), // 약간 둥근 모서리
      ),
      padding: EdgeInsets.zero,
    );

    // 기본 텍스트 스타일
    const TextStyle defaultTextStyle = TextStyle(
      fontSize: medium,
      color: Colors.white,
      fontFamily: "CookieRun",
    );

    // 외부 스타일이 제공되면 병합, 아니면 기본 스타일 사용
    final ButtonStyle effectiveStyle =
        style == null ? defaultStyle : defaultStyle.merge(style);
    // 외부 텍스트 스타일이 제공되면 그것을 사용, 아니면 기본 텍스트 스타일 사용
    final TextStyle effectiveTextStyle = textStyle ?? defaultTextStyle;

    return ElevatedButton(
      style: effectiveStyle,
      onPressed: isLoading ? null : onPressed, // 로딩 중이면 onPressed 비활성화
      child: isLoading
          ? const SizedBox(
              // 로딩 인디케이터 크기 조절을 위해 SizedBox 사용
              height: 24, // 예시 크기, xxLarge / 2 정도
              width: 24, // 예시 크기
              child: CircularProgressIndicator(
                strokeWidth: 3.0, // 선 굵기
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white), // 인디케이터 색상
              ),
            )
          : Text(
              text,
              style: effectiveTextStyle,
            ),
    );
  }
}
