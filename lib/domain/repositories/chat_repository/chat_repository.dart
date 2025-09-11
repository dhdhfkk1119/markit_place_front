import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ChatRepository {
  final _storage = const FlutterSecureStorage();
  StompClient? _client;

  Future<void> connect(Function(Map<String, dynamic>) onMessageReceived) async {
    final token = await _storage.read(key: "accessToken"); // ✅ 저장된 JWT 불러오기

    _client = StompClient(
      config: StompConfig(
        url: 'ws://192.168.0.128:8080/ws/chat', // 서버 WebSocket 주소
        onConnect: (StompFrame frame) {
          print("STOMP connected!");
          _client!.subscribe(
            destination: '/topic/chat',
            callback: (frame) {
              if (frame.body != null) {
                final data = jsonDecode(frame.body!);
                onMessageReceived(data);
              }
            },
          );
        },
        beforeConnect: () async {
          print("connecting...");
          await Future.delayed(const Duration(milliseconds: 200));
        },
        onWebSocketError: (err) => print("WebSocket Error: $err"),
        stompConnectHeaders: {"Authorization": "Bearer $token"}, // ✅ 토큰 헤더 추가
        webSocketConnectHeaders: {"Authorization": "Bearer $token"},
      ),
    );

    _client!.activate();
  }

  void sendMessage(int receiverId, String message) {
    final payload = {
      "receiverId": receiverId,
      "message": message,
    };

    _client?.send(
      destination: "/app/chat.send", // 서버의 STOMP endpoint
      body: jsonEncode(payload),
    );
  }

  void disconnect() {
    _client?.deactivate();
  }
}
