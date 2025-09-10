import 'package:flutter/material.dart';
import '../../main.dart';

class ExceptionHandler {
  static void handleException(dynamic exception, StackTrace stackTrace) {
    // 여기서 예외를 처리하거나 로깅할 수 있습니다.
    print('Exception occurred: $exception');
    print('StackTrace: $stackTrace');

    final mContext = navigatorKey.currentContext;

    ScaffoldMessenger.of(mContext!).showSnackBar(
      SnackBar(content: Text("$exception")),
    );
  }
}
