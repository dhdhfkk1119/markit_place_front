import 'package:flutter/material.dart';

// 앱의 주요 색상 정의
final Color kAppPrimaryColor =
    Colors.deepPurpleAccent.withOpacity(0.1); // 요청된 기본 색상 (투명도 있음)
const Color kAppSecondaryColor =
    Color(0xFFEDE7F6); // Colors.deepPurple[50] - 매우 연한 보라색
const Color kAppButtonSolidColor =
    Colors.deepPurpleAccent; // 버튼 등에 사용할 단색 Primary 계열

ThemeData theme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: "CookieRun", // 앱 전체 기본 폰트를 "CookieRun"으로 설정
    colorScheme: ColorScheme.fromSeed(
      seedColor: kAppButtonSolidColor,
      primary: kAppPrimaryColor,
      secondary: kAppSecondaryColor,
      error: Colors.redAccent,
    ),
    appBarTheme: _appBarTheme(),
    elevatedButtonTheme: _elevatedButtonTheme(),
    outlinedButtonTheme: _outlinedButtonTheme(),
    inputDecorationTheme: _inputDecorationTheme(),
  );
}

AppBarTheme _appBarTheme() {
  return const AppBarTheme(
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      // fontFamily: null, // AppBar는 이제 기본 폰트를 상속받으므로, null이면 CookieRun 적용됨
      // 만약 AppBar만 다른 폰트를 사용하고 싶다면 여기에 명시
    ),
    centerTitle: true,
    backgroundColor: Colors.black12,
    elevation: 0,
  );
}

ElevatedButtonThemeData _elevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor: kAppButtonSolidColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        // fontFamily: "CookieRun", // 이미 ThemeData에서 설정했으므로 중복 선언 불필요 (단, 다른 폰트/스타일 원할 시 명시)
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

OutlinedButtonThemeData _outlinedButtonTheme() {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: kAppSecondaryColor,
      foregroundColor: kAppButtonSolidColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide.none,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        // fontFamily: "CookieRun", // 이미 ThemeData에서 설정했으므로 중복 선언 불필요
      ),
    ),
  );
}

InputDecorationTheme _inputDecorationTheme() {
  return InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: const BorderSide(color: kAppButtonSolidColor, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(color: Colors.redAccent.shade200),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(color: Colors.redAccent.shade700, width: 2.0),
    ),
    // InputDecoration의 labelText, hintText 등에도 기본 폰트가 적용됩니다.
    // 만약 다른 스타일을 원하면 labelStyle, hintStyle 등을 여기에 정의할 수 있습니다.
  );
}
