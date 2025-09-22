class CommunityList {
  final int id;
  final String title;
  final String topic;
  final String location;
  final String preview;
  final String thumbnail;
  final int? likeCount;
  final int? viewCount;
  final String createdAt;
  final int? commentCount;
  final bool isLiked; // isLiked 필드 추가

  CommunityList({
    required this.id,
    required this.title,
    required this.topic,
    required this.location,
    required this.preview,
    required this.thumbnail,
    this.likeCount,
    this.viewCount,
    required this.createdAt,
    this.commentCount,
    this.isLiked = false,
  });

  factory CommunityList.fromMap(Map<String, dynamic> data) {
    return CommunityList(
      id: data['id'] as int? ?? 0,
      title: data['title'] as String? ?? '',
      topic: data['topic'] as String? ?? '',
      location: data['location'] as String? ?? '',
      preview: data['preview'] as String? ?? '',
      thumbnail: data['thumbnail'] as String? ?? '',
      likeCount: data['likeCount'] as int? ?? 0,
      viewCount: data['viewCount'] as int? ?? 0,
      createdAt: data['createdAt'] as String? ?? '',
      commentCount: data['commentCount'] as int? ?? 0,
      isLiked: data['isLiked'] as bool? ?? false,
    );
  }
}
