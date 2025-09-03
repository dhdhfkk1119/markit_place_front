import 'package:flutter/material.dart';

const double fiveGap = 5.0;
const double tenGap = 10.0;
const double twenGap = 20.0;
const double thiGap = 30.0;
const double fortGap = 30.0;
const double fifGap = 50.0;
const double handGap = 100.0;

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getDrawerWidth(BuildContext context) {
  return getScreenWidth(context) * 0.6;
}
