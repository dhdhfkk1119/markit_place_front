import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';

import '../../_core/constants/assets.dart'; // 사이즈 상수 사용 가능

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // 1. CustomElevatedButton의 스타일을 직접 정의 (CustomSubmitButton 구조 차용)
    final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.secondary, // 배경색: 세컨더리 컬러 (연보라)
      foregroundColor:
          Colors.deepPurpleAccent, // 글자/아이콘 색상: kAppButtonSolidColor (진보라)
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // 모양: 네모
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: medium, vertical: small), // 적절한 기본 패딩 (size.dart 상수 사용)
    );

    // 2. 버튼 텍스트의 스타일 정의
    final TextStyle elevatedButtonTextStyle =
        (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
      fontFamily: Fonts.cookieRun, // 폰트: 쿠키런
      color: Colors.deepPurpleAccent, // 글자색: 진보라 (foregroundColor와 일치)
      // fontSize는 theme.textTheme.labelLarge의 것을 따름
    );

    return ElevatedButton(
      style: elevatedButtonStyle,
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 24, // 로딩 아이콘 크기 (필요시 size.dart 상수 사용)
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                // 로딩 인디케이터 색상을 버튼의 foregroundColor와 일치시킴
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
              ),
            )
          : Text(
              text,
              style: elevatedButtonTextStyle,
            ),
    );
  }
}
