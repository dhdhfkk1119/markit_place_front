import '../chat_model/chat_message.dart';

class ChatMessageDto {
  final String content;
  final bool isMine;
  final MessageType type;
  final String time;
  final int senderId;
  final int itemId;

  ChatMessageDto({
    required this.content,
    required this.isMine,
    required this.type,
    required this.time,
    required this.senderId,
    required this.itemId,
  });

  factory ChatMessageDto.fromModel(ChatMessageModel model, int myId) {
    return ChatMessageDto(
      content: model.message,
      isMine: model.sender.id == myId,
      type: model.messageType,
      time: model.createdAt,
      senderId: model.sender.id,
      itemId: model.itemId,
    );
  }

  ChatMessageDto copyWith({
    String? content,
    bool? isMine,
    MessageType? type,
    String? time,
    int? senderId,
    int? itemId,
  }) {
    return ChatMessageDto(
      content: content ?? this.content,
      isMine: isMine ?? this.isMine,
      type: type ?? this.type,
      time: time ?? this.time,
      senderId: senderId ?? this.senderId,
      itemId: itemId ?? this.itemId,
    );
  }
}
