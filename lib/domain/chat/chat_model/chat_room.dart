import 'package:markit_place_front/domain/chat/chat_dto/chat_room_dto.dart';
import 'package:markit_place_front/domain/models/user.dart';

class ChatRoom {
  final int roomId;
  final User otherUser;
  final String lastMessage;
  final String createdAt;

  ChatRoom({
    required this.roomId,
    required this.otherUser,
    required this.lastMessage,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> data) {
    return ChatRoom(
      roomId: data['roomId'],
      otherUser: User(
        id: data['receiverId'],
        loginId: data['receiverName'],
        name: data['receiverName'],
        status: MemberStatus.ACTIVE,
      ),
      lastMessage: data['lastMessage'],
      createdAt: data['createdAt'],
    );
  }
}
