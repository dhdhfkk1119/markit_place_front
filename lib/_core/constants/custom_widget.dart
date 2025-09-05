import 'package:flutter/material.dart';

class CustomWidget {
  static Text buildTitle(String title,
      {double? size, Color? color, FontWeight? weight}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: size ?? 18,
        fontFamily: "CookieRun",
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? Colors.black,
      ),
    );
  }

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
}
