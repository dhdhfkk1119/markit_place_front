class CommunityPostWriteDTO {
  final String title;
  final String content;
  final String location;
  final int topicId;
  final List<String> images;

  CommunityPostWriteDTO({
    required this.title,
    required this.content,
    required this.location,
    required this.topicId,
    required this.images,
  });

  factory CommunityPostWriteDTO.fromModel(Map<String, dynamic> json) {
    return CommunityPostWriteDTO(
      title: json['title'] as String,
      content: json['content'] as String,
      location: json['location'] as String,
      topicId: json['topicId'] as int,
      images:
          (json['images'] as List<dynamic>).map((e) => e.toString()).toList(),
    );
  }
}
