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


  CommunityPostWriteDTO copyWith({
    String? title,
    String? content,
    String? location,
    int? topicId,
    List<String>? images,
  }) {
    return CommunityPostWriteDTO(
      title: title ?? this.title,
      content: content ?? this.content,
      location: location ?? this.location,
      topicId: topicId ?? this.topicId,
      images: images ?? this.images,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'title' : title,
      'content' : content,
      'location' : location,
      'topicId' : topicId,
      'images' : images,
    };
  }

  Map<String, dynamic> fromJson() {
    return {
      'title': title,
      'content': content,
      'location': location,
      'topicId': topicId,
      'images': images,
    };
  }
}
