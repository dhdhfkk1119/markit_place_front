import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'chat_room_repository.dart';

String Url = baseUrl;

class ChatRepository {
  final _storage = const FlutterSecureStorage();
  Completer<void>? _connectCompleter; // 연결 완료를 기다릴 수 있는 객체 추가
  StompClient? _client;

  // 연결 상태 확인을 위한 getter
  bool get isConnected => _client != null && _client!.connected;

  // STOMP 클라이언트 초기화 및 연결
  Future<void> connect({
    required int roomId,
    required Function(Map<String, dynamic>) onMessageReceived,
  }) async {
    if (isConnected) return; // 이미 연결되어 있으면 즉시 반환

    _connectCompleter = Completer<void>(); // 새로운 Completer 생성

    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      print("[ChatRepository] Access token not found. Cannot connect.");
      _connectCompleter!.completeError("Access token not found");
      return;
    }

    _client = StompClient(
      config: StompConfig(
        url: Url + '/ws-stomp',
        useSockJS: true,
        onConnect: (StompFrame frame) {
          print("[ChatRepository] STOMP connected successfully!");
          _connectCompleter!.complete(); // 연결 완료를 알립니다.
          // 연결 성공 후, 특정 방의 메시지 구독
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
          print("[ChatRepository] Attempting to connect...");
        },
        onWebSocketError: (error) {
          print("[ChatRepository] WebSocket Error: $error");
          _connectCompleter!.completeError(error); // 연결 실패를 알립니다.
        },
        onStompError: (error) {
          print("[ChatRepository] STOMP Protocol Error: ${error.body}");
          _connectCompleter!.completeError(error); // 연결 실패를 알립니다.
        },
        webSocketConnectHeaders: {"Authorization": "Bearer $token"},
        stompConnectHeaders: {"Authorization": "Bearer $token"},
      ),
    );
    _client!.activate();

    await _connectCompleter!.future; // 연결이 완료될 때까지 기다립니다.
  }

  // 메시지 전송
  Future<int> sendMessage({
    required int? roomId,
    required int receiverId,
    required String message,
    required int itemId,
  }) async {
    int currentRoomId = roomId ??
        await ChatRoomRepository.getOrCreateRoom(receiverId, itemId, message);

    final payload = {
      "roomId": currentRoomId,
      "receiveId": receiverId,
      "message": message,
      "itemId": itemId,
    };

    _client?.send(
      destination: "/app/chat/sendMessage",
      body: jsonEncode(payload),
    );

    return currentRoomId;
  }

  // 연결 해제
  void disconnect() {
    if (_client != null) {
      _client!.deactivate();
      _client = null;
      print("[ChatRepository] STOMP disconnected.");
    }
  }
}
