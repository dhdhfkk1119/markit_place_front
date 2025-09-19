import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // 삭제
import '../../../_core/dtos/api_response_dto.dart';
import '../../../_core/dtos/error_dto.dart';
import '../../../_core/utils/error_utils.dart';
import '../../../_core/utils/my_http.dart'; // Imports global dio
import '../dtos/find_id_masked_response_dto.dart'; // DTO for masked ID

// ----- 추가: 비밀번호 재설정 관련 DTO import -----
import '../dtos/password_reset_dtos.dart';

class FindAccountRepository {
  final Dio _dio = dio; // Use global dio instance

  // Constructor (LogInterceptor is likely handled globally or in other repositories)
  // FindAccountRepository() {
  //   if (!_dio.interceptors.any((interceptor) => interceptor is LogInterceptor)) {
  //     _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  //   }
  // }

  /// 이메일로 마스킹된 아이디 조회
  Future<String> getMaskedId(String email) async {
    try {
      final dioResponse = await _dio.post(
        '/email/account/find-id/masked',
        data: {'email': email},
      );

      final apiResponse = ApiResponseDto<FindIdMaskedResponseDto>.fromJson(
        dioResponse.data as Map<String, dynamic>,
        fromJsonT: FindIdMaskedResponseDto.fromJson,
      );

      if (apiResponse.success && apiResponse.response != null) {
        return apiResponse.response!.maskedLoginId;
      } else if (!apiResponse.success && apiResponse.error != null) {
        throw Exception(
            apiResponse.error!.message ?? '마스킹된 아이디 조회 중 알 수 없는 서버 오류');
      } else {
        throw Exception('마스킹된 아이디 조회 중 알 수 없는 오류 (서버 응답 형식 확인 필요)');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, '[GetMaskedId Error]'));
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print('[GetMaskedId Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }

  /// 이메일로 아이디 전체 발송
  Future<String> sendFullIdToEmail(String email) async {
    try {
      final dioResponse = await _dio.post(
        '/email/account/find-id/send-email',
        data: {'email': email},
      );

      final apiResponse = ApiResponseDto<String>.fromJson(
        dioResponse.data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.response != null) {
        return apiResponse.response!; // Server returns a direct message string
      } else if (!apiResponse.success && apiResponse.error != null) {
        throw Exception(
            apiResponse.error!.message ?? '아이디 전체 이메일 발송 중 알 수 없는 서버 오류');
      } else {
        throw Exception('아이디 전체 이메일 발송 중 알 수 없는 오류 (서버 응답 형식 확인 필요)');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, '[SendFullIdToEmail Error]'));
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print('[SendFullIdToEmail Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }

  // --- 비밀번호 재설정 메소드들 ---

  /// 비밀번호 재설정용 인증 코드 발송
  Future<void> sendPasswordResetCode(
      SendPasswordResetCodeRequestDto requestDto) async {
    try {
      final dioResponse = await _dio.post(
        '/email/account/password/send-code', // Spring API 경로
        data: requestDto.toJson(),
      );
      final apiResponse = ApiResponseDto<String>.fromJson(
        dioResponse.data as Map<String, dynamic>,
      );
      if (!apiResponse.success) {
        throw Exception(apiResponse.error?.message ?? '인증 코드 발송에 실패했습니다.');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, '[SendPasswordResetCode Error]'));
    } catch (e) {
      throw Exception(
          '[SendPasswordResetCode Error - General] ${extractErrorMessage(e)}');
    }
  }

  /// 비밀번호 재설정용 인증 코드 확인 및 임시 토큰 발급
  Future<PasswordResetTokenResponseDto> confirmPasswordResetCode(
      ConfirmPasswordResetCodeRequestDto requestDto) async {
    try {
      final dioResponse = await _dio.post(
        '/email/account/password/confirm-code', // Spring API 경로
        data: requestDto.toJson(),
      );
      final apiResponse =
          ApiResponseDto<PasswordResetTokenResponseDto>.fromJson(
        dioResponse.data as Map<String, dynamic>,
        fromJsonT: PasswordResetTokenResponseDto.fromJson,
      );
      if (apiResponse.success && apiResponse.response != null) {
        return apiResponse.response!;
      } else {
        throw Exception(
            apiResponse.error?.message ?? '인증 코드 확인 또는 토큰 발급에 실패했습니다.');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, '[ConfirmPasswordResetCode Error]'));
    } catch (e) {
      throw Exception(
          '[ConfirmPasswordResetCode Error - General] ${extractErrorMessage(e)}');
    }
  }

  /// 임시 토큰을 사용하여 비밀번호 최종 재설정
  Future<void> resetPassword(PasswordResetRequestDto requestDto) async {
    try {
      final dioResponse = await _dio.post(
        '/email/account/password/reset', // Spring API 경로
        data: requestDto.toJson(),
      );
      final apiResponse = ApiResponseDto<String>.fromJson(
        dioResponse.data as Map<String, dynamic>,
      );
      if (!apiResponse.success) {
        throw Exception(apiResponse.error?.message ?? '비밀번호 재설정에 실패했습니다.');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, '[ResetPassword Error]'));
    } catch (e) {
      throw Exception(
          '[ResetPassword Error - General] ${extractErrorMessage(e)}');
    }
  }

  // DioException 처리를 위한 내부 헬퍼 메소드
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
      finalErrorMessage = extractErrorMessage(e);
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

// Provider for FindAccountRepository // 삭제
// final findAccountRepositoryProvider = Provider<FindAccountRepository>((ref) { // 삭제
//   return FindAccountRepository(); // 삭제
// }); // 삭제
