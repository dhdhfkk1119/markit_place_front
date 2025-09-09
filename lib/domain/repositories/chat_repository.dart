import '../models/chat.dart';

class ChatRepository {

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