import 'package:dio/dio.dart';

/// DioException 또는 일반 Exception으로부터 사용자에게 보여줄 에러 메시지를 추출합니다.
String extractErrorMessage(Object error) {
  if (error is DioException) {
    final dioError = error;
    String message = dioError.message ?? '요청 중 오류가 발생했습니다.'; // 기본 Dio 에러 메시지

    if (dioError.response != null && dioError.response!.data != null) {
      final responseData = dioError.response!.data;

      if (responseData is Map<String, dynamic>) {
        // 케이스 1: {"success": bool, "response": ..., "error": {"message": "...", "code": "..."}}
        if (responseData.containsKey('error') &&
            responseData['error'] != null &&
            responseData['error'] is Map<String, dynamic>) {
          final errorData = responseData['error'] as Map<String, dynamic>;
          if (errorData.containsKey('message') &&
              errorData['message'] != null &&
              errorData['message'].toString().isNotEmpty) {
            message = errorData['message'].toString();
          }
          // 케이스 2: {"success": bool, "message": "..."} 또는 {"message": "..."}
        } else if (responseData.containsKey('message') &&
            responseData['message'] != null &&
            responseData['message'].toString().isNotEmpty) {
          message = responseData['message'].toString();
        }
        // 여기에 다른 일반적인 API 에러 응답 구조가 있다면 추가 (예: 스프링 기본 오류 응답)
        else if (responseData.containsKey('error') &&
            responseData['error'] is String) {
          // Spring Boot 기본 오류 메시지 (ex: "Not Found", "Bad Request")
          message = responseData['error'] as String;
        } else if (responseData.containsKey('detail') &&
            responseData['detail'] is String) {
          // DRF 같은 프레임워크의 상세 오류 메시지
          message = responseData['detail'] as String;
        }
      } else if (responseData is String && responseData.isNotEmpty) {
        // 케이스 3: 서버가 단순 문자열로 에러를 보낸 경우
        message = responseData;
      }
    }
    return message;
  } else if (error is String) {
    return error; // 이미 문자열인 경우 그대로 반환
  } else {
    // 기타 Exception
    String errorMessage = error.toString();
    // "Exception: " 또는 "Error: " 같은 접두어 제거
    if (errorMessage.startsWith("Exception: ")) {
      errorMessage = errorMessage.substring("Exception: ".length);
    }
    // 일부 커스텀 Exception은 이미 메시지만 포함할 수 있으므로, Error: 접두어는 선택적으로 제거
    // else if (errorMessage.startsWith("Error: ")) {
    //   errorMessage = errorMessage.substring("Error: ".length);
    // }
    return errorMessage.isNotEmpty ? errorMessage : '알 수 없는 오류가 발생했습니다.';
  }
}
