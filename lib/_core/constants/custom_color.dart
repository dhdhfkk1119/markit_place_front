import 'package:flutter/material.dart';

class CustomColor {
  static const List<dynamic> colorElementList = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    "A",
    "B",
    "C",
    "D",
    "E",
    'F'
  ];

  /// 자주 쓰는 색상을 상수로 선언
  // 투명색
  static const invisible = Color(0x00000000);

  // 빨간색
  /// custom red color.
  /// * bright [00 ~ FF], default [FF]
  /// * intensity [00 ~ FF], default [FF]
  static getCustomRed({String? bright, String? intensity}) {
    for (dynamic e in colorElementList) {
      if (e == bright?.substring(0, 1)) {
        final colorSeed = "0x${bright ?? "FF"}${intensity ?? "FF"}0000";
        return Color(int.parse(colorSeed));
      }
    }
  }
}
