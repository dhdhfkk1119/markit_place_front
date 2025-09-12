import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ChatRepository {
  final _storage = const FlutterSecureStorage();
  StompClient? _client;

  Future<void> connect(
      int roomId, Function(Map<String, dynamic>) onMessageReceived) async {
    final token = await _storage.read(key: "accessToken");

    _client = StompClient(
      config: StompConfig(
        url: 'ws://192.168.0.128:8080/ws-stomp', // 서버 WebSocket 주소
        onConnect: (StompFrame frame) {
          print("STOMP connected!");
          // 구독하는 받는 주소
          _client!.subscribe(
            destination: '/topic/chat/room/$roomId',
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
        stompConnectHeaders: {"Authorization": "Bearer $token"},
        webSocketConnectHeaders: {"Authorization": "Bearer $token"},
      ),
    );

    _client!.activate();
  }

  // 보내는 주소
  void sendMessage(int roomId, int receiverId, String message) {
    final payload = {
      "roomId": roomId,
      "receiveId": receiverId,
      "message": message,
    };

    _client?.send(
      destination: "/app/chat/sendMessage",
      body: jsonEncode(payload),
    );
  }

  void disconnect() {
    _client?.deactivate();
  }
}
