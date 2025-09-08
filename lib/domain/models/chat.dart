class Chat {
  final String id;
  final String username;
  final String message;
  final String imageData;
  final bool isRead;

  Chat ({
    required this.id,
    required this.username,
    required this.message,
    required this.imageData,
    required this.isRead,
  });
}