import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';

class CustomSmallActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomSmallActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle? baseStyle = Theme.of(context).elevatedButtonTheme.style;

    return ElevatedButton(
      style: baseStyle?.copyWith(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: medium, vertical: small),
        ),
        minimumSize: WidgetStateProperty.all<Size?>(const Size(0, xLarge)),
        textStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (Set<WidgetState> states) {
          final TextStyle? existingThemeTextStyle =
              baseStyle.textStyle?.resolve(states);
          final Color? themeForegroundColor =
              baseStyle.foregroundColor?.resolve(states);

          const double targetFontSize = medium;

          // 기존 테마 스타일이 있다면 그것을 기반으로 하되, 폰트와 크기는 명시적으로 지정
          if (existingThemeTextStyle != null) {
            return existingThemeTextStyle.copyWith(
              fontFamily: "CookieRun", // CookieRun 폰트 명시적 지정
              fontSize: targetFontSize,
              color: themeForegroundColor ?? existingThemeTextStyle.color,
            );
          } else {
            // 기존 테마 스타일이 없다면 새로 생성하며 폰트 명시
            return TextStyle(
              fontFamily: "CookieRun", // CookieRun 폰트 명시적 지정
              fontSize: targetFontSize,
              color: themeForegroundColor,
            );
          }
        }),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
