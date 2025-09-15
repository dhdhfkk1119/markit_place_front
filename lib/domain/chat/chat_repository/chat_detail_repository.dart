// chat_detail_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:markit_place_front/domain/chat/chat_dto/chat_message_dto.dart';
import '../chat_model/chat_message.dart';

final _storage = FlutterSecureStorage();

class ChatDetailRepository {
  Future<List<ChatMessageDto>> getMyRoomMessage({
    required int roomId,
    required int myId,
  }) async {
    print("[Repository] getMyRoomMessage 호출: roomId=$roomId, myId=$myId");

    final token = await _storage.read(key: "accessToken");
    print("[Repository] 토큰 읽기: $token");

    if (token == null) {
      throw Exception("토큰이 없어 채팅방을 불러올 수 없습니다");
    }

    try {
      print("[Repository] Dio 요청 시작");
      final response = await Dio().get(
        'http://192.168.0.128:8080/api/chat/room/$roomId',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print("[Repository] Dio 요청 완료, statusCode=${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> chatList = data["content"] ?? [];
        print("[Repository] chatList 길이: ${chatList.length}");

        final rooms = chatList.map((data) {
          final model = ChatMessageModel.fromJson(data);
          return ChatMessageDto.fromModel(model, roomId);
        }).toList();

        print("[Repository] 메시지 파싱 완료: ${rooms.length}개");
        return rooms;
      }

      throw Exception("채팅메세지 목록을 가져오는데 실패 (HTTP ${response.statusCode})");
    } catch (e, st) {
      print("[Repository] 에러 발생: $e");
      print(st);
      throw Exception("채팅방메세지 목록을 가져오는데 실패");
    }
  }
}
