import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'assets.dart';

/// [CustomWidget]
///
/// ## 목적
/// 프로젝트 전반에서 반복적으로 사용될 수 있는 간단한 UI 위젯 생성 유틸리티를 제공합니다.
/// Text 위젯(주로 제목 스타일)과 IconButton 위젯을 일관된 스타일과 기본값으로 쉽게 생성할 수 있도록 돕습니다.
///
/// ## 주요 사용처
/// ### buildTitle
/// - RegisterForm (예: "이메일 인증하기" 섹션 제목)
/// - CustomPopUp (예: 팝업창 제목, 사용자 이름/상품 이름 표시)
///
/// ### buildIcon
/// - CustomPopUp (예: 신고하기 ListTile의 아이콘, 닫기 ListTile의 아이콘)
class CustomWidget {
  // 공용 제목 Text 위젯 생성 유틸리티
  static Text buildTitle(String title,
      {double? size,
      Color? color,
      FontWeight? weight,
      TextDecoration? decoration,
      TextOverflow? overflow}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: size ?? 18,
        fontFamily: Assets.Fonts.cookieRun,
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? Colors.black,
        decoration: decoration ?? TextDecoration.none,
        overflow: overflow ?? TextOverflow.ellipsis,
      ),
    );
  }

  // 공용 IconButton 위젯 생성 유틸리티
  static IconButton buildIcon(
    Icon icon, {
    double? size,
    Color? color,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed ?? () {},
      icon: Icon(
        icon.icon,
        size: size ?? icon.size,
        color: color ?? icon.color,
      ),
    );
  }

  // Toast 메세지 보여주는 메서드 추가 (글 작성하기에 필요)
  static void showToast(String message) {
    print(message);
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
