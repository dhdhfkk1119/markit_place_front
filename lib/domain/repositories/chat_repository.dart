import '../../_core/utils/my_http.dart';
import '../models/chat.dart';

void main() async {
  final response = await ChatRepository.findAllChatRoom(userId: 1);
  print("${response["body"]}");
}

class ChatRepository {
  
  // 전체 채팅방 조회
  static Future<Map<String, dynamic>> findAllChatRoom({required int userId}) async {
    try {
      final response = await dio.get("$baseUrl/chat/rooms", queryParameters: {
        "userId": userId
      });

      final responseBody = response.data;
      if (response.statusCode != 200) return {"statusCode": response.statusCode, "errorMessage": responseBody["errorMessage"], "body": null};

      return {"statusCode": response.statusCode, "errorMessage": null, "body": responseBody};
    } catch (e) {
      return {"statusCode": 500, "errorMessage": "서버 오류가 발생했습니다.", "body": null};
    }
  }

  // 상세 채팅방 조회
  static Future<Map<String, dynamic>> findDetailChatRoom({required int roomId}) async {
    return {"test": false};
  }

  // 채팅 작성
  static Future<Map<String, dynamic>> writeChat({required int roomId, required Chat? chat}) async {
    return {"test": false};
  }

  // 채팅 수정?
  static Future<Map<String, dynamic>> editChat({required int roomId, required Chat? chat}) async {
    return {"test": false};
  }

  // 채팅 삭제?
  static Future<Map<String, dynamic>> deleteChat({required int chatId}) async {
    return {"test": false};
  }
}