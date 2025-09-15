/// API 응답 실패 시 반환되는 공통 에러 정보를 담는 DTO

/// ## 주요 사용처
/// 1. `ApiResponseDto`: 서버 응답의 'error' 부분을 파싱하거나 생성 시 사용됨.
///    - `ApiResponseDto.fromJson()` 내부에서 `ErrorDto.fromJson()` 호출함.
///    - `ApiResponseDto.toJson()` 내부에서 `error?.toJson()` 호출함.

/// 2. Repository 계층 (예: `MemberAuthRepository`):
///    - API 호출 후 반환된 에러 응답(종종 `DioException.response.data['error']`에 포함됨)을
///      `ErrorDto.fromJson()`으로 직접 파싱하여 상세 에러 정보를 추출하는 데 사용될 수 있음.

/// 3. Notifier/Provider 계층 (예: `AuthNotifier`):
///    - Repository로부터 전달받은 에러 정보(커스텀 Exception 내 ErrorDto 또는 직접 파싱된 ErrorDto)를
///      바탕으로 UI에 표시할 사용자 친화적 에러 메시지를 생성할 때 참조될 수 있음.

class ErrorDto {
  final String? message; // 에러 메시지 내용
  final int? status; // HTTP 상태 코드 (선택적)
  final String? code; // 서버 정의 에러 코드 (선택적)
  final String? field; // 오류 관련 필드명 (선택적)

  ErrorDto({
    this.message,
    this.status,
    this.code,
    this.field,
  });

  /// JSON 맵으로부터 ErrorDto 객체를 생성함.
  factory ErrorDto.fromJson(Map<String, dynamic> json) {
    return ErrorDto(
      message: json['message'] as String?,
      status: json['status'] as int?,
      code: json['code'] as String?,
      field: json['field'] as String?,
    );
  }

  /// ErrorDto 객체를 JSON 맵으로 변환함.
  /// (주로 디버깅 또는 로깅 시 유용)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (message != null) data['message'] = message;
    if (status != null) data['status'] = status;
    if (code != null) data['code'] = code;
    if (field != null) data['field'] = field;
    return data;
  }
}
