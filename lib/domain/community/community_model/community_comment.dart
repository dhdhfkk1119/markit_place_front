class CommunityComment {
  final int id;
  final String content;
  final String writerName;
  final String createdAt;
  final String? imageUrl;
  final int? likeCount;

  CommunityComment({
    required this.id,
    required this.content,
    required this.writerName,
    required this.createdAt,
    this.imageUrl,
    this.likeCount,
  });

  factory CommunityComment.fromMap(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'],
      content: json['content'],
      writerName: json['writerName'],
      createdAt: json['createdAt'],
      imageUrl: json['imageUrl'],
      likeCount: json['likeCount'] ?? 0,
    );
  }
}
