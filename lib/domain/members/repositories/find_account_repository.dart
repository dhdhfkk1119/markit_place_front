import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For Provider
import 'package:markit_place_front/_core/dtos/api_response_dto.dart';
import 'package:markit_place_front/_core/dtos/error_dto.dart';
import 'package:markit_place_front/_core/utils/error_utils.dart';
import 'package:markit_place_front/_core/utils/my_http.dart'; // Imports global dio
import 'package:markit_place_front/domain/members/dtos/find_id_masked_response_dto.dart'; // DTO for masked ID

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
        '/email/account/find-id/masked', // <-- 경로 수정됨
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
      String finalErrorMessage;
      ErrorDto? parsedErrorDto;

      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        if (responseData.containsKey('error') &&
            responseData['error'] != null &&
            responseData['error'] is Map<String, dynamic>) {
          try {
            parsedErrorDto = ErrorDto.fromJson(
                responseData['error'] as Map<String, dynamic>);
          } catch (parseError) {
            print(
                '[GetMaskedId Error - DioException] Failed to parse ErrorDto: $parseError');
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
          '[GetMaskedId Error - DioException] Final Message: $finalErrorMessage (Dio Status: ${e.response?.statusCode})');
      throw Exception(finalErrorMessage);
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
        '/email/account/find-id/send-email', // <-- 경로 수정됨
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
      String finalErrorMessage;
      ErrorDto? parsedErrorDto;

      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        if (responseData.containsKey('error') &&
            responseData['error'] != null &&
            responseData['error'] is Map<String, dynamic>) {
          try {
            parsedErrorDto = ErrorDto.fromJson(
                responseData['error'] as Map<String, dynamic>);
          } catch (parseError) {
            print(
                '[SendFullIdToEmail Error - DioException] Failed to parse ErrorDto: $parseError');
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
          '[SendFullIdToEmail Error - DioException] Final Message: $finalErrorMessage (Dio Status: ${e.response?.statusCode})');
      throw Exception(finalErrorMessage);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print('[SendFullIdToEmail Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }
}

// Provider for FindAccountRepository
final findAccountRepositoryProvider = Provider<FindAccountRepository>((ref) {
  return FindAccountRepository();
});
