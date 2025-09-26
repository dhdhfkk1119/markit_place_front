import './error_dto.dart';

/// 서버의 공통 API 응답 구조를 표준화하기 위한 제네릭 DTO 클래스임.
/// 이 DTO는 API 요청의 성공 여부, 성공 시 실제 데이터(제네릭 타입 T),
/// 그리고 실패 시 에러 정보(ErrorDto)를 일관된 방식으로 캡슐화함.

/// ## 주요 사용처
/// 1. Repository 계층 (예: `MemberAuthRepository`):
///    - Dio 또는 http 클라이언트를 통해 서버로부터 받은 JSON 응답을 파싱 시 사용됨.
///    - `ApiResponseDto.fromJson(jsonData, fromJsonT: YourSpecificDataDto.fromJson)`
///      형태로 호출되어, JSON 응답을 ApiResponseDto 객체로 변환함.
///    - `fromJsonT` 또는 `fromJsonListT` 콜백 함수를 통해 `response` 필드의
///      제네릭 타입 T에 해당하는 실제 데이터 DTO (예: `LoginResponseDataDto`,
///      `MemberRegisterResponseDataDto`)를 올바르게 파싱함.
///    - Repository는 파싱된 `ApiResponseDto`의 `success`, `response`, `error` 필드를
///      확인하여 비즈니스 로직을 처리하거나, Notifier/Provider에게 적절한 데이터를 전달함.

/// 2. 특정 데이터 DTO 정의 시 (예: `LoginResponseDataDto.dart`):
///    - 이전에는 각 API 응답마다 `success`, `response`, `error` 필드를 가진
///      개별 래퍼 DTO를 만들었으나, `ApiResponseDto<T>`가 이 공통 래퍼 역할을 함.
///    - 따라서 각 API 응답에 대한 DTO는 이제 실제 데이터의 구조만을 정의하고 (예: `LoginResponseDataDto`),
///      이것이 `ApiResponseDto<T>`의 `T` 타입으로 사용됨.

/// `ApiResponseDto.toJson()` 메소드는 주로 디버깅 또는 특수한 요청 시나리오를 위해 제공되며,
/// 일반적인 클라이언트-서버 간 요청 흐름에서는 `fromJson()`이 더 빈번하게 사용됨.

class ApiResponseDto<T> {
  final bool success; // API 요청 성공 여부
  final T? response; // API 성공 시 실제 응답 데이터 (제네릭 타입)
  final ErrorDto? error; // API 실패 시 에러 정보

  ApiResponseDto({
    required this.success,
    this.response,
    this.error,
  });

  /// JSON 맵으로부터 `ApiResponseDto` 객체를 생성함.
  ///
  /// `fromJsonT`는 `response` 필드가 단일 객체일 때 해당 객체를 파싱하는 함수임.
  /// `fromJsonListT`는 `response` 필드가 객체 리스트일 때 해당 리스트를 파싱하는 함수임.
  /// 제네릭 타입 `T`가 기본형(String, int, double, bool, dynamic)이거나, 파싱 함수가 제공되지 않으면 직접 할당을 시도함.
  factory ApiResponseDto.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJsonT,
    T Function(List<dynamic>)? fromJsonListT,
  }) {
    T? responseData;
    // 서버 응답 구조가 'response' 또는 'data' 등 혼재될 수 있으므로, 우선순위로 파싱
    final responseJson = json['response'] ?? json['data'];

    if (responseJson != null) {
      if (fromJsonT != null && responseJson is Map<String, dynamic>) {
        responseData = fromJsonT(responseJson);
      } else if (fromJsonListT != null && responseJson is List<dynamic>) {
        responseData = fromJsonListT(responseJson);
      } else if (T == dynamic ||
          T == String ||
          T == int ||
          T == double ||
          T == bool ||
          responseJson is T) {
        responseData = responseJson as T?;
      }
      // 지원하지 않는 타입이거나 적절한 파서가 없는 경우 responseData는 null로 유지됨.
    }

    return ApiResponseDto<T>(
      success: json['success'] as bool,
      response: responseData,
      error: json['error'] != null
          ? ErrorDto.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  /// `ApiResponseDto` 객체를 JSON 맵으로 변환함.
  /// (주로 클라이언트에서 서버로 요청 시에는 잘 사용되지 않음)
  ///
  /// `toJsonT`는 `response` 필드가 단일 객체일 때 해당 객체를 JSON으로 변환하는 함수임.
  /// `toJsonListT`는 `response` 필드가 객체 리스트일 때 해당 리스트를 JSON으로 변환하는 함수임.
  Map<String, dynamic> toJson({
    Map<String, dynamic> Function(T)? toJsonT,
    List<dynamic> Function(T)? toJsonListT,
  }) {
    dynamic responseJson;
    if (response != null) {
      if (toJsonT != null && response is! List) {
        responseJson = toJsonT(response as T);
      } else if (toJsonListT != null && response is List) {
        responseJson = toJsonListT(response as T);
      } else if (response is String ||
          response is int ||
          response is double ||
          response is bool ||
          response is List) {
        responseJson = response;
      }
    }

    return {
      'success': success,
      'response': responseJson,
      'error': error?.toJson(),
    };
  }
}

class ProfileDataDto {
  final int id;
  final String? name; // Nullable로 변경
  final String status; // Non-nullable 유지
  final String? profileImageBase64; // Nullable로 변경

  ProfileDataDto({
    required this.id,
    this.name, // Nullable 파라미터
    required this.status, // Non-nullable 파라미터
    this.profileImageBase64, // Nullable 파라미터
  });

  factory ProfileDataDto.fromJson(Map<String, dynamic> json) {
    return ProfileDataDto(
      id: json['id'] as int,
      name: json['name'] as String?, // String?으로 파싱
      status: json['status'] as String, // String으로 파싱 (null이면 여기서 에러 발생)
      profileImageBase64: json['profileImageBase64'] as String?, // String?으로 파싱
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name, // null일 수 있음
      'status': status,
      'profileImageBase64': profileImageBase64, // null일 수 있음
    };
  }
}
