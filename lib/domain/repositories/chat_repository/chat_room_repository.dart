import '../../../_core/utils/my_http.dart';

class ChatRoomRepository {
  // 전체 채팅방 조회
  static Future<Map<String, dynamic>> findAllChatRoom(
      {required int userId}) async {
    try {
      final response = await dio
          .get("$baseUrl/chat/rooms", queryParameters: {"userId": userId});

      final responseBody = response.data;
      if (response.statusCode != 200)
        return {
          "statusCode": response.statusCode,
          "errorMessage": responseBody["errorMessage"],
          "body": null
        };

      return {
        "statusCode": response.statusCode,
        "errorMessage": null,
        "body": responseBody
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "errorMessage": "서버 오류가 발생했습니다.",
        "body": null
      };
    }
  }

  // 상세 채팅방 조회
  static Future<Map<String, dynamic>> findDetailChatRoom(
      {required int roomId}) async {
    return {"test": false};
  }
}
