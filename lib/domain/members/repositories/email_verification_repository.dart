import 'package:dio/dio.dart';
import '../../../_core/dtos/api_response_dto.dart';
import '../../../_core/dtos/error_dto.dart';
import '../../../_core/utils/error_utils.dart';
import '../../../_core/utils/my_http.dart';

/// 이메일 인증 관련 API 요청을 처리하는 리포지토리입니다.
///
/// 인증 코드 발송 요청 및 코드 확인 기능을 담당합니다.
class EmailVerificationRepository {
  final Dio _dio = dio; // 전역 dio 인스턴스 사용

  EmailVerificationRepository() {
    if (!_dio.interceptors
        .any((interceptor) => interceptor is LogInterceptor)) {
      _dio.interceptors
          .add(LogInterceptor(requestBody: true, responseBody: true));
    }
  }

  /// 회원가입을 위한 이메일 인증 코드를 요청합니다.
  ///
  /// {@macro common_api_error_handling}
  /// @param email 인증 코드를 받을 이메일 주소.
  /// @throws Exception API 통신 실패 또는 서버 에러 발생 시.
  Future<void> requestEmailVerification(String email) async {
    try {
      final dioResponse = await _dio.post(
        '/email/register/send-code', // Endpoint는 기존 MemberAuthRepository와 동일
        data: {'email': email},
      );

      // 일반적인 성공/실패 메시지 API의 경우, 반환 DTO가 단순 String이거나 없을 수 있음
      // 여기서는 ApiResponseDto<String>을 사용한다고 가정
      final apiResponse = ApiResponseDto<String>.fromJson(
        dioResponse.data as Map<String, dynamic>,
        // String은 기본 타입이므로 fromJsonT/fromJsonListT 불필요
      );

      if (apiResponse.success) {
        print('인증 코드 발송 요청 성공: $email, 응답 메시지: ${apiResponse.response}');
        // 성공 시 별도 반환값 없음 (void)
      } else {
        throw Exception(apiResponse.error?.message ?? '인증 코드 발송에 실패했습니다.');
      }
    } on DioException catch (e) {
      final errorMessage =
          _handleDioError(e, '[RequestEmailVerification Error - DioException]');
      throw Exception(errorMessage);
    } catch (e) {
      print('[RequestEmailVerification Error - General] ${e.toString()}');
      throw Exception('인증 코드 발송 요청 중 예상치 못한 오류가 발생했습니다.');
    }
  }

  /// 회원가입을 위한 이메일 인증 코드를 확인합니다.
  ///
  /// {@macro common_api_error_handling}
  /// @param email 이메일 주소.
  /// @param code 사용자가 입력한 인증 코드.
  /// @return 인증 성공 시 `true`.
  /// @throws Exception API 통신 실패, 서버 에러 또는 인증 실패 시.
  Future<bool> confirmEmailVerification(String email, String code) async {
    try {
      final dioResponse = await _dio.post(
        '/email/register/confirm-code', // Endpoint는 기존 MemberAuthRepository와 동일
        data: {'email': email, 'code': code},
      );

      final apiResponse = ApiResponseDto<String>.fromJson(
        dioResponse.data as Map<String, dynamic>,
      );

      if (apiResponse.success) {
        print('이메일 인증 성공: $email, 응답 메시지: ${apiResponse.response}');
        return true;
      } else {
        // 인증 실패 시 에러 메시지를 포함하여 예외 발생
        throw Exception(apiResponse.error?.message ?? '인증 코드 확인에 실패했습니다.');
      }
    } on DioException catch (e) {
      final errorMessage =
          _handleDioError(e, '[ConfirmEmailVerification Error - DioException]');
      throw Exception(errorMessage);
    } catch (e) {
      print('[ConfirmEmailVerification Error - General] ${e.toString()}');
      throw Exception('인증 코드 확인 중 예상치 못한 오류가 발생했습니다.');
    }
  }

  /// DioException 발생 시 에러 메시지를 파싱하고 로깅하는 내부 헬퍼 메소드.
  String _handleDioError(DioException e, String logPrefix) {
    String finalErrorMessage;
    ErrorDto? parsedErrorDto;

    if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
      final responseData = e.response!.data as Map<String, dynamic>;
      if (responseData.containsKey('error') &&
          responseData['error'] != null &&
          responseData['error'] is Map<String, dynamic>) {
        try {
          parsedErrorDto =
              ErrorDto.fromJson(responseData['error'] as Map<String, dynamic>);
        } catch (parseError) {
          print('$logPrefix - Failed to parse ErrorDto: $parseError');
        }
      }
    }

    if (parsedErrorDto?.message != null &&
        parsedErrorDto!.message!.isNotEmpty) {
      finalErrorMessage = parsedErrorDto.message!;
    } else {
      finalErrorMessage =
          extractErrorMessage(e); // _core/utils/error_utils.dart의 함수
    }
    print(
        '$logPrefix Final Message: $finalErrorMessage (Dio Status: ${e.response?.statusCode})');
    if (parsedErrorDto != null) {
      print(
          '$logPrefix Parsed ErrorDto: Code: ${parsedErrorDto.code}, Field: ${parsedErrorDto.field}, Status: ${parsedErrorDto.status}');
    }
    return finalErrorMessage;
  }
}

/// {@template common_api_error_handling}
/// **에러 처리 참고:**
/// 이 메소드는 API 요청 중 발생하는 `DioException`을 내부적으로 처리하려고 시도합니다.
/// `DioException.response.data`에 `error` 필드가 포함되어 있고, 이 필드가 `ErrorDto` 형식에
/// 부합하는 경우, 해당 `ErrorDto.message`를 우선적으로 사용합니다.
/// 그렇지 않은 경우 `extractErrorMessage(e)` 유틸리티 함수를 통해 일반적인 Dio 에러 메시지를 추출합니다.
/// 최종적으로 처리된 에러 메시지를 포함하는 `Exception`을 발생시킵니다.
/// 일반적인 `Exception`의 경우에도 해당 메시지를 담아 throw 합니다.
/// {@endtemplate}
