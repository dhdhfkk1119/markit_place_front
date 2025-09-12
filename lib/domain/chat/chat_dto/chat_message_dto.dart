import '../chat_model/chat_message.dart';

class ChatMessageDto {
  final String content;
  final bool isMine;
  final MessageType type;
  final String time;

  ChatMessageDto({
    required this.content,
    required this.isMine,
    required this.type,
    required this.time,
  });

  factory ChatMessageDto.fromModel(ChatMessageModel model, int myId) {
    return ChatMessageDto(
      content: model.message,
      isMine: model.sender.id == myId,
      type: model.messageType,
      time: model.createdAt,
    );
  }
}
