import '../user.dart';

enum MessageType { TEXT, IMAGE, FILE, SYSTEM }

class ChatMessageModel {
  final int messageId;
  final int roomId;
  final User sender;
  final User receiver;
  final String message;
  final String createdAt;
  final MessageType messageType;
  final List<String> imageUrls;

  ChatMessageModel({
    required this.messageId,
    required this.roomId,
    required this.sender,
    required this.receiver,
    required this.message,
    required this.createdAt,
    required this.messageType,
    required this.imageUrls,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json['messageId'],
      roomId: json['roomId'],
      sender: User(
        id: json['senderId'],
        loginId: json['senderName'], // 서버에서 loginId 대신 name만 내려줄 수도 있으니 조정 필요
        name: json['senderName'],
        status: MemberStatus.ACTIVE, // 서버 응답에 상태값이 없으면 기본 ACTIVE 처리
      ),
      receiver: User(
        id: json['receiverId'],
        loginId: json['receiverName'],
        name: json['receiverName'],
        status: MemberStatus.ACTIVE,
      ),
      message: json['message'],
      createdAt: json['createdAt'],
      messageType: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['messageType']}',
      ),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
    );
  }
}
