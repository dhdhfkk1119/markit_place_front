import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart'; // size.dart 임포트

// 기본 강조 색상
final Color kAppPrimaryColor = Color(0x1A7C4DFF); // 투명도 있는 진보라
// 보조 색상
const Color kAppSecondaryColor = Color(0xFFEDE7F6); // 연보라
// 버튼용 단색 강조 색상
const Color kAppButtonSolidColor = Colors.deepPurpleAccent; // 진보라

// 앱 전체 테마 데이터
ThemeData theme() {
  // 기본 TextTheme을 가져와서 CookieRun 폰트 적용
  final TextTheme baseTextTheme = ThemeData.light().textTheme;
  final TextTheme cookieRunTextTheme =
      baseTextTheme.apply(fontFamily: "CookieRun");

  return ThemeData(
    useMaterial3: true, // Material 3 사용
    fontFamily: "CookieRun", // 최상위 fontFamily도 유지 (혹시 모를 경우 대비)
    // 색상 구성표
    colorScheme: ColorScheme.fromSeed(
      seedColor: kAppButtonSolidColor, // 기준 색상 (진보라)
      primary: kAppPrimaryColor, // 기본 강조색 (투명도 있는 진보라)
      secondary: kAppSecondaryColor, // 보조색 (연보라)
      error: Colors.redAccent, // 오류 표시색 (빨강 계열)
    ),
    textTheme: cookieRunTextTheme, // 모든 Text 위젯에 CookieRun 폰트가 적용된 TextTheme 사용
    appBarTheme: _appBarTheme(cookieRunTextTheme),
    elevatedButtonTheme: _elevatedButtonTheme(cookieRunTextTheme),
    outlinedButtonTheme: _outlinedButtonTheme(cookieRunTextTheme),
    inputDecorationTheme:
        _inputDecorationTheme(cookieRunTextTheme), // TextTheme 전달
  );
}

// AppBar 테마
AppBarTheme _appBarTheme(TextTheme textTheme) {
  return AppBarTheme(
    titleTextStyle: textTheme.titleLarge?.copyWith(
      color: Colors.white,
    ),
    centerTitle: true,
    backgroundColor: Colors.black12,
    elevation: 0,
  );
}

// ElevatedButton 테마
ElevatedButtonThemeData _elevatedButtonTheme(TextTheme textTheme) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, xxLarge),
      backgroundColor: kAppButtonSolidColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(small),
      ),
      textStyle: textTheme.labelLarge
          ?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
    ),
  );
}

// OutlinedButton 테마
OutlinedButtonThemeData _outlinedButtonTheme(TextTheme textTheme) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: kAppSecondaryColor,
      foregroundColor: kAppButtonSolidColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(small),
      ),
      side: BorderSide.none,
      textStyle: textTheme.labelLarge
          ?.copyWith(fontWeight: FontWeight.w700, color: kAppButtonSolidColor),
    ),
  );
}

// InputDecoration (입력 필드) 테마
InputDecorationTheme _inputDecorationTheme(TextTheme textTheme) {
  // TextTheme 인자 추가
  return InputDecorationTheme(
    labelStyle: textTheme.bodyMedium
        ?.copyWith(color: Colors.grey.shade600), // CookieRun 폰트 적용됨
    hintStyle: textTheme.bodySmall
        ?.copyWith(color: Colors.grey.shade500), // CookieRun 폰트 적용됨
    errorStyle: textTheme.bodySmall
        ?.copyWith(color: Colors.redAccent.shade700), // CookieRun 폰트 적용됨
    // contentPadding: EdgeInsets.symmetric(vertical: small, horizontal: medium), // 필요에 따라 패딩 조절

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(medium),
      borderSide:
          BorderSide(color: Colors.grey.shade400), // 테마의 colorScheme.outline 고려
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(medium),
      borderSide:
          BorderSide(color: Colors.grey.shade400), // 테마의 colorScheme.outline 고려
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(medium),
      borderSide: const BorderSide(
          color: kAppButtonSolidColor,
          width: 2.0), // 테마의 colorScheme.primary 고려
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(medium),
      borderSide: BorderSide(
          color: Colors.redAccent.shade200), // 테마의 colorScheme.error 고려
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(medium),
      borderSide: BorderSide(
          color: Colors.redAccent.shade700,
          width: 2.0), // 테마의 colorScheme.error 고려
    ),
  );
}
