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
    print('CommunityComment.fromMap received JSON: $json');
    return CommunityComment(
      id: json['id'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      writerName: json['writerName'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      likeCount: json['likeCount'] as int? ?? 0,
    );
  }
}
