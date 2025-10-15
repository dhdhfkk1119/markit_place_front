class TopicDTO {
  final int id;
  final String name;

  TopicDTO({required this.id, required this.name});

  factory TopicDTO.fromJson(Map<String, dynamic> json) {
    return TopicDTO(
      id: json["id"] as int,
      name: json["name"] as String,
    );
  }
}

class CommunityCategoryDTO {
  final int id;
  final String name;
  final List<TopicDTO> topics;

  CommunityCategoryDTO({
    required this.id,
    required this.name,
    required this.topics,
  });

  factory CommunityCategoryDTO.fromModel(CommunityCategoryDTO model) {
    return CommunityCategoryDTO(
      id: model.id,
      name: model.name,
      topics: model.topics,
    );
  }
}
