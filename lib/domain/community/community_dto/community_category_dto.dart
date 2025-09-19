class CommunityCategoryDTO {
  final int id;
  final String name;

  CommunityCategoryDTO({
    required this.id,
    required this.name,
  });

  factory CommunityCategoryDTO.fromJson(Map<String, dynamic> json) {
    return CommunityCategoryDTO(
      id: json["id"] as int,
      name: json["name"] as String,
    );
  }
}
