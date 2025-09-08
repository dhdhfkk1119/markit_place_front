class GeminiDTO {
  final String mimeType;
  final String imageData;

  GeminiDTO({required this.mimeType, required this.imageData});

  GeminiDTO.fromMap(Map<String, dynamic> map)
      : this.mimeType = map["mimeType"],
        this.imageData = map["imageData"];
}
