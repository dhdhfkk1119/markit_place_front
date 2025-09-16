// lib/domain/members/dtos/id_check_response.dto.dart

class IdCheckResponseDataDto {
  final bool available;

  IdCheckResponseDataDto({required this.available});

  factory IdCheckResponseDataDto.fromJson(Map<String, dynamic> json) {
    return IdCheckResponseDataDto(
      available: json['available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
    };
  }
}
