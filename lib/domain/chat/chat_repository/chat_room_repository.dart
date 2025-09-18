import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/domain/chat/chat_dto/chat_room_dto.dart';
import 'package:markit_place_front/domain/chat/chat_model/chat_room.dart';

final _storage = FlutterSecureStorage();

String Url = baseUrl;

class ChatRoomRepository {
  // 서버에 room 요청 (없으면 생성, 있으면 기존 roomId 반환)
  static Future<int> getOrCreateRoom(
      int receiverId, int itemId, String message) async {
    final token = await _storage.read(key: "accessToken");

    final response = await dio.post(
      Url + '/chat/rooms/create',
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
      data: {"receiveId": receiverId, "itemId": itemId, "message": message},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final roomId = data['roomId'] ?? data['id'];
      if (roomId == null) throw Exception("roomId가 응답에 없습니다");
      return roomId;
    } else {
      throw Exception("채팅방을 가져오거나 생성할 수 없습니다.");
    }
  }

  Future<List<ChatRoomDTO>> getMyRoom() async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception("토큰이 없어 채팅방을 불러올 수 없습니다");
    }

    try {
      print("요청 URL: http://192.168.0.128:8080/api/chat/rooms");
      print("Authorization 헤더: Bearer $token");

      final response = await dio.get(
        baseUrl + '/chat/rooms',
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      print("응답 코드: ${response.statusCode}");
      print("응답 바디: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data["content"];
        return dataList.map((data) {
          final chatRoomModel = ChatRoom.fromJson(data);
          return ChatRoomDTO.fromModel(chatRoomModel);
        }).toList();
      }
      throw Exception("채팅방 목록 실패 (HTTP ${response.statusCode})");
    } on DioError catch (e) {
      print("DioError 발생: ${e.response?.statusCode}, ${e.response?.data}");
      throw Exception("채팅방 목록을 가져오는데 실패");
    }
  }
}
