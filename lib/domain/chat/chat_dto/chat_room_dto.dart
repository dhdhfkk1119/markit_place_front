import 'package:markit_place_front/domain/chat/chat_model/chat_room.dart';

class ChatRoomDTO {
  final int roomId;
  final int otherUserId;
  final String otherUserName;
  final String lastMessage;
  final String createdAt;

  ChatRoomDTO({
    required this.roomId,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.createdAt,
  });

  factory ChatRoomDTO.fromModel(ChatRoom dto) {
    return ChatRoomDTO(
      roomId: dto.roomId,
      otherUserId: dto.otherUser.id,
      otherUserName: dto.otherUser.name,
      lastMessage: dto.lastMessage,
      createdAt: dto.createdAt,
    );
  }

  ChatRoomDTO copyWith({
    int? roomId,
    int? otherUserId,
    String? otherUserName,
    String? lastMessage,
    String? createdAt,
  }) {
    return ChatRoomDTO(
      roomId: roomId ?? this.roomId,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
