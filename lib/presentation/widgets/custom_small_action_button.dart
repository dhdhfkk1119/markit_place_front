import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';

/// [CustomSmallActionButton]
///
/// ## 목적
/// TextFormField 옆 또는 작은 영역의 보조 액션용 소형 버튼.
/// ElevatedButton 테마를 유지하며 크기(패딩, 최소 높이) 및 텍스트 스타일 축소.
/// 공간 제약적이거나, 주 CTA 버튼보다 덜 강조되어야 하는 경우 사용.
///
/// ## 주요 사용처
/// - RegisterForm (아이디 중복확인, 이메일 인증번호 전송 버튼)
/// - ListItem (수정, 삭제 버튼)

// 폼 내 작은 액션 버튼 위젯
class CustomSmallActionButton extends StatelessWidget {
  final String text; // 버튼 텍스트
  final VoidCallback onPressed; // 버튼 클릭 콜백

  const CustomSmallActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ElevatedButton 테마 기반으로 크기/패딩 조절
    final ButtonStyle? baseStyle = Theme.of(context).elevatedButtonTheme.style;

    return ElevatedButton(
      style: baseStyle?.copyWith(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(
              horizontal: middle, vertical: small), // 작은 버튼용 패딩
        ),
        minimumSize:
            WidgetStateProperty.all<Size?>(const Size(0, third)), // 최소 높이
        textStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (Set<WidgetState> states) {
          final TextStyle? existingThemeTextStyle =
              baseStyle?.textStyle?.resolve(states);
          final Color? themeForegroundColor =
              baseStyle?.foregroundColor?.resolve(states);

          // 작은 버튼용 폰트 크기
          const double targetFontSize = middle;

          // 기존 테마 폰트 크기 관련 로직 (현재는 targetFontSize로 고정됨)
          // final double? currentThemeFontSize = existingThemeTextStyle?.fontSize;
          // if (currentThemeFontSize != null && currentThemeFontSize > 0) {
          // targetFontSize = currentThemeFontSize * 0.9;
          // }

          if (existingThemeTextStyle != null) {
            return existingThemeTextStyle.copyWith(
              fontFamily: "CookieRun",
              fontSize: targetFontSize,
              color: themeForegroundColor ??
                  existingThemeTextStyle.color, // 테마 전경색 우선
            );
          } else {
            return TextStyle(
              fontFamily: "CookieRun",
              fontSize: targetFontSize,
              color: themeForegroundColor,
            );
          }
        }),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 탭 영역 버튼 크기에 맞춤
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
