class ChatRoomDTO {
  final int roomId;
  final int loginId;
  final int otherId;
  final String loginName;
  final String otherName;
  final String lastMessage;
  final String createdAt;

  ChatRoomDTO({
    required this.roomId,
    required this.loginId,
    required this.otherId,
    required this.loginName,
    required this.otherName,
    required this.lastMessage,
    required this.createdAt,
  });

  factory ChatRoomDTO.fromMap(Map<String, dynamic> data) {
    return ChatRoomDTO(
      roomId: data['roomId'],
      loginId: data['loginId'],
      otherId: data['otherId'],
      loginName: data['loginName'],
      otherName: data['otherName'],
      lastMessage: data['message'],
      createdAt: data['createdAt'],
    );
  }
}
