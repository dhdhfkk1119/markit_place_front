import 'package:flutter/material.dart';

// 기본 강조 색상 (투명도 0.1, Colors.deepPurpleAccent 기반)
final Color kAppPrimaryColor = Color(0x1A7C4DFF);
// 보조 색상 (연한 보라색, Colors.deepPurple[50])
const Color kAppSecondaryColor = Color(0xFFEDE7F6);
// 버튼용 단색 강조 색상 (Colors.deepPurpleAccent)
const Color kAppButtonSolidColor = Colors.deepPurpleAccent;

// 앱 전체 테마 데이터
ThemeData theme() {
  return ThemeData(
    useMaterial3: true, // Material 3 디자인 시스템 사용 여부
    fontFamily: "CookieRun", // 앱 전체 기본 폰트: CookieRun
    // 앱 전반의 색상 구성표 (ColorScheme)
    colorScheme: ColorScheme.fromSeed(
      seedColor: kAppButtonSolidColor, // 색상표 생성 기준 색상
      primary: kAppPrimaryColor, // 기본 색상 (강조)
      secondary: kAppSecondaryColor, // 보조 색상
      error: Colors.redAccent, // 오류 표시용 색상
    ),
    appBarTheme: _appBarTheme(), // AppBar 전용 테마
    elevatedButtonTheme: _elevatedButtonTheme(), // ElevatedButton 전용 테마
    outlinedButtonTheme: _outlinedButtonTheme(), // OutlinedButton 전용 테마
    inputDecorationTheme: _inputDecorationTheme(), // TextField 등 입력 필드 전용 테마
  );
}

// AppBar 테마 정의
AppBarTheme _appBarTheme() {
  return const AppBarTheme(
    // AppBar 제목 텍스트 스타일
    titleTextStyle: TextStyle(
      color: Colors.white, // 제목 텍스트 색상: 흰색
      fontSize: 20, // 제목 텍스트 크기: 20
      // fontFamily는 ThemeData에서 "CookieRun" 상속
    ),
    centerTitle: true, // 제목 중앙 정렬 여부
    backgroundColor: Colors.black12, // AppBar 배경색: 투명도 있는 검은색
    elevation: 0, // AppBar 그림자 깊이: 없음
  );
}

// ElevatedButton 테마 정의
ElevatedButtonThemeData _elevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50), // 버튼 최소 크기: 너비 최대, 높이 50
      backgroundColor: kAppButtonSolidColor, // 버튼 배경색
      foregroundColor: Colors.white, // 버튼 전경색 (텍스트, 아이콘 등): 흰색
      // 버튼 모양: 둥근 모서리 사각형
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // 모서리 둥글기 반경: 8
      ),
      // 버튼 텍스트 스타일
      textStyle: const TextStyle(
        fontSize: 16, // 텍스트 크기: 16
        // fontFamily는 ThemeData에서 "CookieRun" 상속
        fontWeight: FontWeight.w700, // 텍스트 굵기: 볼드 (700)
      ),
    ),
  );
}

// OutlinedButton 테마 정의
OutlinedButtonThemeData _outlinedButtonTheme() {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: kAppSecondaryColor, // 버튼 배경색
      foregroundColor: kAppButtonSolidColor, // 버튼 전경색 (텍스트, 아이콘 등)
      // 버튼 모양: 둥근 모서리 사각형
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // 모서리 둥글기 반경: 8
      ),
      side: BorderSide.none, // 버튼 테두리: 없음
      // 버튼 텍스트 스타일
      textStyle: const TextStyle(
        fontSize: 14, // 텍스트 크기: 14
        fontWeight: FontWeight.w700, // 텍스트 굵기: 볼드 (700)
        // fontFamily는 ThemeData에서 "CookieRun" 상속
      ),
    ),
  );
}

// InputDecoration (입력 필드) 테마 정의
InputDecorationTheme _inputDecorationTheme() {
  return InputDecorationTheme(
    // 기본 테두리 스타일
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0), // 모서리 둥글기 반경: 20
      borderSide: const BorderSide(color: Colors.grey), // 테두리 색상: 회색
    ),
    // 활성화 상태 테두리 스타일
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(color: Colors.grey.shade400), // 테두리 색상: 연한 회색
    ),
    // 포커스 상태 테두리 스타일
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(
          color: kAppButtonSolidColor, width: 2.0), // 테두리 색상: 버튼 강조색, 두께: 2.0
    ),
    // 오류 상태 테두리 스타일
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide:
          BorderSide(color: Colors.redAccent.shade200), // 테두리 색상: 연한 빨간색
    ),
    // 포커스된 오류 상태 테두리 스타일
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(
          color: Colors.redAccent.shade700,
          width: 2.0), // 테두리 색상: 진한 빨간색, 두께: 2.0
    ),
    // labelStyle, hintStyle 등은 ThemeData의 fontFamily("CookieRun") 자동 상속
  );
}
