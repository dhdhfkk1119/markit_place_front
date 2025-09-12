import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/domain/chat/chat_dto/chat_room_dto.dart';
import 'package:markit_place_front/domain/chat/chat_model/chat_room.dart';

final _storage = FlutterSecureStorage();

class ChatRoomRepository {
  // 서버에 room 요청 (없으면 생성, 있으면 기존 roomId 반환)
  static Future<int> getOrCreateRoom(int receiverId) async {
    final token = await _storage.read(key: "accessToken");

    final response = await dio.post(
      'http://192.168.0.128:8080/api/chat/send', // 메시지 전송용 엔드포인트
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
      data: {
        "receiveId": receiverId,
        "message": "",
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      // 서버에서 반환하는 roomId를 받아옴
      return data['roomId'];
    } else {
      throw Exception("채팅방을 가져오거나 생성할 수 없습니다.");
    }
  }

  Future<List<ChatRoomDTO>> getMyRoom({required int userId}) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception("토큰이 없어 채팅방을 불러올 수 없습니다");
    }

    try {
      final response = await dio.get(
        'http://192.168.0.128:8080/api/chat/rooms',
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data;
        final List<ChatRoomDTO> rooms = dataList.map((data) {
          final chatRoomModel = ChatRoom.fromJson(data);
          return ChatRoomDTO.fromModel(chatRoomModel);
        }).toList();

        return rooms;
      }
      throw Exception("채팅방 목록을 가져오는데 실패 (HTTP ${response.statusCode})");
    } catch (e) {
      throw Exception("채팅방 목록을 가져오는데 실패");
    }
  }
}
