import 'package:markit_place_front/domain/chat/chat_model/chat_room.dart';

class ChatRoomDTO {
  final int roomId;
  final int otherId;
  final String otherName;
  final String lastMessage;
  final String createdAt;

  ChatRoomDTO({
    required this.roomId,
    required this.otherId,
    required this.otherName,
    required this.lastMessage,
    required this.createdAt,
  });

  factory ChatRoomDTO.fromModel(ChatRoom dto) {
    return ChatRoomDTO(
      roomId: dto.roomId,
      otherId: dto.otherUser.id,
      otherName: dto.otherUser.name,
      lastMessage: dto.lastMessage,
      createdAt: dto.createdAt,
    );
  }
}
