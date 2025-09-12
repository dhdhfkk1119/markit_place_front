import '../../dtos/chat_dto/chat_room_dto.dart';
import '../user.dart';

class ChatRoom {
  final int roomId;
  final User loginUser;
  final User otherUser;
  final String message;
  final String createdAt;

  ChatRoom({
    required this.roomId,
    required this.loginUser,
    required this.otherUser,
    required this.message,
    required this.createdAt,
  });

  factory ChatRoom.fromDto(ChatRoomDTO dto) {
    final loginUser = User(
      id: dto.loginId,
      loginId: '',
      name: dto.loginName,
      status: MemberStatus.ACTIVE,
    );

    final otherUser = User(
      id: dto.otherId,
      loginId: '',
      name: dto.otherName,
      status: MemberStatus.ACTIVE,
    );

    return ChatRoom(
      roomId: dto.roomId,
      loginUser: loginUser,
      otherUser: otherUser,
      message: dto.lastMessage,
      createdAt: dto.createdAt,
    );
  }
}
