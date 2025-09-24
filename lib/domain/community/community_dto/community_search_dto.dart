class CommunityListDTO {
  final int id;
  final String title;
  final String? preview;
  final String? thumbnail;
  final String topic;
  final int? likeCount;
  final int? viewCount;
  final int? commentCount;
  final String createdAt;
  final String location;

  CommunityListDTO({
    required this.id,
    required this.title,
    this.preview,
    this.thumbnail,
    required this.topic,
    this.likeCount,
    this.viewCount,
    this.commentCount,
    required this.createdAt,
    required this.location,
  });

  factory CommunityListDTO.fromJson(Map<String, dynamic> json) {
    return CommunityListDTO(
      id: json['id'],
      title: json['title'],
      preview: json['preview'],
      thumbnail: json['thumbnail'],
      topic: json['topic'],
      likeCount: json['likeCount'],
      viewCount: json['viewCount'],
      commentCount: json['commentCount'],
      createdAt: json['createdAt'],
      location: json['location'],
    );
  }
}