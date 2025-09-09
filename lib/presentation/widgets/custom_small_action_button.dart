import 'package:flutter/material.dart';

/// [CustomSmallActionButton]
///
/// ## 목적
/// TextFormField 옆이나 작은 영역에 배치되어 보조적인 액션을 수행하는 작은 크기의 버튼이다.
/// ElevatedButton 테마를 유지하면서도, 크기(패딩, 최소 높이)와 텍스트 스타일이 축소됐다.
/// 공간이 제한적이거나, 주된 CTA(Call To Action) 버튼보다 시각적으로 덜 강조되어야 하는 경우에 사용된다.
///
/// ## 주요 사용처
/// - RegisterForm (아이디 중복확인 버튼, 이메일 인증번호 전송 버튼)
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
    // 앱 테마의 ElevatedButton 스타일을 기반으로 하되, 크기/패딩 등을 조절
    final ButtonStyle? baseStyle = Theme.of(context).elevatedButtonTheme.style;

    // 작은 크기의 ElevatedButton 반환
    return ElevatedButton(
      style: baseStyle?.copyWith(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(
              horizontal: 14, vertical: 8), // 작은 버튼에 맞는 패딩
        ),
        minimumSize: WidgetStateProperty.all<Size?>(
            const Size(0, 36)), // WidgetStateProperty로 변경 및 타입 명시
        textStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (Set<WidgetState> states) {
          // WidgetStateProperty 및 Set<WidgetState>로 변경
          final TextStyle? existingThemeTextStyle =
              baseStyle?.textStyle?.resolve(states);
          final Color? themeForegroundColor =
              baseStyle?.foregroundColor?.resolve(states);

          double targetFontSize = 14.0; // 기본 폰트 크기

          // existingThemeTextStyle에서 fontSize를 안전하게 가져옵니다.
          final double? currentThemeFontSize = existingThemeTextStyle?.fontSize;

          if (currentThemeFontSize != null && currentThemeFontSize > 0) {
            targetFontSize = currentThemeFontSize * 0.9;
          }

          if (existingThemeTextStyle != null) {
            return existingThemeTextStyle.copyWith(
              fontFamily: "CookieRun", // CookieRun 폰트 적용
              fontSize: targetFontSize,
              color: themeForegroundColor ??
                  existingThemeTextStyle.color, // 테마 전경색 우선, 없으면 기존 텍스트 스타일 색상
            );
          } else {
            return TextStyle(
              fontFamily: "CookieRun", // CookieRun 폰트 적용
              fontSize: targetFontSize,
              color: themeForegroundColor, // 테마 전경색 적용 (null일 수 있음, 그러면 기본값 따름)
            );
          }
        }),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 탭 영역을 버튼 크기에 맞게 조절
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
