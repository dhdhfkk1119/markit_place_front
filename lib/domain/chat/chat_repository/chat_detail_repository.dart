import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../_core/utils/my_http.dart';
import '../chat_dto/chat_message_dto.dart';
import '../chat_model/chat_message.dart';

final _storage = FlutterSecureStorage();

String Url = baseUrl;

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
        Url + '/chat/room/$roomId',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print("[Repository] Dio 요청 완료, statusCode=${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> chatList = data["content"] ?? [];
        print("[Repository] chatList 길이: ${chatList.length}");

        final rooms = <ChatMessageDto>[];
        for (var data in chatList) {
          try {
            final model = ChatMessageModel.fromJson(data);
            final dto = ChatMessageDto.fromModel(model, myId);
            rooms.add(dto);
          } catch (e) {
            print("메시지 파싱 중 오류 발생: $e, 데이터: $data");
            // 문제가 있는 데이터는 건너뛰고 계속 진행
          }
        }

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

  Future<void> markMessagesAsRead({
    required int roomId,
    required int myId,
  }) async {
    print("[Repository] markMessagesAsRead 호출: roomId=$roomId, myId=$myId");

    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception("토큰이 없어 읽음 처리를 할 수 없습니다.");
    }

    try {
      print("[Repository] Dio PUT 요청 시작");
      final response = await Dio().put(
        Url + '/chat/room/$roomId/read',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print("[Repository] Dio PUT 요청 완료, statusCode=${response.statusCode}");
      if (response.statusCode != 200) {
        throw Exception("읽음 처리 실패 (HTTP ${response.statusCode})");
      }
    } catch (e, st) {
      print("[Repository] 에러 발생: $e");
      print(st);
      throw Exception("읽음 처리 실패");
    }
  }
}
