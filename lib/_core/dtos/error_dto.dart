// lib/_core/dtos/error_dto.dart

class ErrorDto {
  final String? message;
  final String? code;
  // 필요에 따라 다른 공통 에러 필드 추가 가능 (예: Map<String, String> validationErrors)

  ErrorDto({
    this.message,
    this.code,
  });

  factory ErrorDto.fromJson(Map<String, dynamic> json) {
    return ErrorDto(
      message: json['message'] as String?,
      code: json['code'] as String?,
    );
  }

  // 필요한 경우 추가적인 유틸리티 메서드
  // Map<String, dynamic> toJson() {
  //   return {
  //     'message': message,
  //     'code': code,
  //   };
  // }
}
