import '../models/chat_room.dart';
import '../models/user.dart';

class ChatDTO {
  final String id;
  final ChatRoom room;
  final User user;
  final String message;

  ChatDTO({
    required this.id,
    required this.room,
    required this.user,
    required this.message
  });
}