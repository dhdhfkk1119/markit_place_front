import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();
final dio = Dio();

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
        "message": "", // 메시지를 보내지 않고 방만 생성
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
}
