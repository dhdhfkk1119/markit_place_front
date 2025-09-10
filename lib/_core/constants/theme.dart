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
  return ThemeData(
    useMaterial3: true, // Material 3 사용
    fontFamily: "CookieRun", // 앱 전체 기본 폰트
    // 색상 구성표
    colorScheme: ColorScheme.fromSeed(
      seedColor: kAppButtonSolidColor, // 기준 색상 (진보라)
      primary: kAppPrimaryColor, // 기본 강조색 (투명도 있는 진보라)
      secondary: kAppSecondaryColor, // 보조색 (연보라)
      error: Colors.redAccent, // 오류 표시색 (빨강 계열)
    ),
    appBarTheme: _appBarTheme(), // AppBar 테마
    elevatedButtonTheme: _elevatedButtonTheme(), // ElevatedButton 테마
    outlinedButtonTheme: _outlinedButtonTheme(), // OutlinedButton 테마
    inputDecorationTheme: _inputDecorationTheme(), // 입력 필드 테마
  );
}

// AppBar 테마
AppBarTheme _appBarTheme() {
  return const AppBarTheme(
    titleTextStyle: TextStyle(
      color: Colors.white, // 제목 텍스트 색상 (흰색)
      fontSize: large, // 제목 텍스트 크기 (24)
    ),
    centerTitle: true, // 제목 중앙 정렬
    backgroundColor: Colors.black12, // 배경색 (투명도 있는 검정)
    elevation: 0, // 그림자 깊이 없음
  );
}

// ElevatedButton 테마
ElevatedButtonThemeData _elevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, xxLarge), // 최소 크기 (높이 48)
      backgroundColor: kAppButtonSolidColor, // 배경색 (진보라)
      foregroundColor: Colors.white, // 전경색 (텍스트, 아이콘 - 흰색)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(small), // 모서리 둥글기 (8)
      ),
      textStyle: const TextStyle(
        fontSize: medium, // 텍스트 크기 (16)
        fontWeight: FontWeight.w700, // 텍스트 굵기 (볼드)
      ),
    ),
  );
}

// OutlinedButton 테마
OutlinedButtonThemeData _outlinedButtonTheme() {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: kAppSecondaryColor, // 배경색 (연보라)
      foregroundColor: kAppButtonSolidColor, // 전경색 (텍스트, 아이콘 - 진보라)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(small), // 모서리 둥글기 (8)
      ),
      side: BorderSide.none, // 테두리 없음
      textStyle: const TextStyle(
        fontSize: medium, // 텍스트 크기 (16)
        fontWeight: FontWeight.w700, // 텍스트 굵기 (볼드)
      ),
    ),
  );
}

// InputDecoration (입력 필드) 테마
InputDecorationTheme _inputDecorationTheme() {
  return InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(medium), // 모서리 둥글기 (16)
      borderSide: const BorderSide(color: Colors.grey), // 테두리 색상 (회색)
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(medium), // 모서리 둥글기 (16)
      borderSide: BorderSide(color: Colors.grey.shade400), // 활성 테두리 색상 (연한 회색)
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(medium), // 모서리 둥글기 (16)
      borderSide: const BorderSide(
          color: kAppButtonSolidColor, width: 2.0), // 포커스 테두리 (진보라)
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(medium), // 모서리 둥글기 (16)
      borderSide:
          BorderSide(color: Colors.redAccent.shade200), // 오류 테두리 색상 (연빨강)
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(medium), // 모서리 둥글기 (16)
      borderSide: BorderSide(
          color: Colors.redAccent.shade700, // 포커스된 오류 테두리 (진빨강)
          width: 2.0),
    ),
  );
}
