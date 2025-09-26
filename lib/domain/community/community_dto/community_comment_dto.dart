class CommunityCommentDTO {
  final int id;
  final String content;
  final String writerName;
  final String createdAt;
  final int likeCount;

  CommunityCommentDTO({
    required this.id,
    required this.content,
    required this.writerName,
    required this.createdAt,
    required this.likeCount,
  });

  factory CommunityCommentDTO.fromJson(Map<String, dynamic> json) {
    return CommunityCommentDTO(
      id: json["id"] as int,
      content: json["content"] as String,
      writerName: json["writerName"] as String,
      createdAt: json["createdAt"] as String,
      likeCount: json["likeCount"] as int,
    );
  }
}
