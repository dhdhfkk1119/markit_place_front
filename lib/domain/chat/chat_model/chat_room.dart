import '../chat_dto/chat_room_dto.dart';
import '../../models/user.dart';

class ChatRoom {
  final int roomId;
  final User otherUser;
  final String lastMessage;
  final String createdAt;
  final int itemId;
  int? unreadMessageCount;

  ChatRoom({
    required this.roomId,
    required this.otherUser,
    required this.lastMessage,
    required this.createdAt,
    required this.itemId,
    this.unreadMessageCount,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> data) {
    return ChatRoom(
      roomId: data['roomId'],
      otherUser: User(
        id: data['otherUserId'],
        loginId: data['otherUserName'],
        name: data['otherUserName'],
        status: MemberStatus.ACTIVE,
      ),
      lastMessage: data['lastMessage'],
      createdAt: data['lastMessageCreatedAt'],
      itemId: data['itemId'],
      unreadMessageCount: data['unreadMessageCount'],
    );
  }
}
