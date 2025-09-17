import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtil {
  // 안드로이드용 아이콘
  final androidSetting = AndroidInitializationSettings("app_icon");

  // 플러그인 인스턴스 생성
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // 푸시 알림 스트림 생성
  static final StreamController<String?> notificationStream =
      StreamController<String?>.broadcast();

  // 푸시 알림을 탭했을 때 호출 되는 콜백 함수
  static void onNotificationTap(NotificationResponse notificationResponse) {
    notificationStream.add(notificationResponse.payload!);
  }

  // 플러그인 초기화
  static Future init() async {
    // Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // 안드로이드 푸시 알림 권한 요청
    if (Platform.isAndroid) {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    }

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  // 일반 푸시 알림 보내기
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails("channel 1", "channel 1 name",
            channelDescription: "channel 1 description",
            importance: Importance.max,
            priority: Priority.high,
            ticker: "ticker");
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

  // 채널 ID에 해당하는 푸시 알림 취소
  static Future cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // 푸시 알림 전체 취소
  static Future cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
