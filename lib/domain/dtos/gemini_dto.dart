class GeminiDTO {
  final String mimeType;
  final String imageData;

  GeminiDTO({required this.mimeType, required this.imageData});

  GeminiDTO.fromMap(Map<String, dynamic> map)
      : mimeType = map["mimeType"],
        imageData = map["imageData"];
}
