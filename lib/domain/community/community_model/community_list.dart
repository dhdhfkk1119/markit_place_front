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
  });

  factory CommunityList.fromMap(Map<String, dynamic> data) {
    return CommunityList(
      id: data['id'],
      title: data['title'],
      topic: data['topic'],
      location: data['location'],
      preview: data['preview'],
      thumbnail: data['thumbnail'],
      likeCount: data['likeCount'] ?? 0,
      viewCount: data['viewCount'] ?? 0,
      createdAt: data['createdAt'],
      commentCount: data['commentCount'] ?? 0,
    );
  }
}
