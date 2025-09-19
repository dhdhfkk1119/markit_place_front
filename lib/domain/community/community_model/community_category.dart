class CommunityCategoryDTO {
  final int id;
  final String name;

  CommunityCategoryDTO({
    required this.id,
    required this.name,
  });

  factory CommunityCategoryDTO.fromModel(CommunityCategoryDTO model) {
    return CommunityCategoryDTO(
      id: model.id,
      name: model.name,
    );
  }
}
