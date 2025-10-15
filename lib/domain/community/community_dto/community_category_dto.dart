import '../community_model/community_category.dart';

class CommunityCategoryDTO {
  final int id;
  final String name;
  final List<TopicDTO> topics;

  CommunityCategoryDTO({
    required this.id,
    required this.name,
    required this.topics,
  });

  factory CommunityCategoryDTO.fromJson(Map<String, dynamic> json) {
    return CommunityCategoryDTO(
      id: json["id"] as int,
      name: json["name"] as String,
      topics: (json["topics"] as List<dynamic>)
          .map((t) => TopicDTO.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
