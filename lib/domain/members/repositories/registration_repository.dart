// D:/workspace-flutter/markit_place_front/lib/domain/members/repositories/registration_repository.dart
import 'package:dio/dio.dart';
import '../../../_core/dtos/api_response_dto.dart';
import '../../../_core/dtos/error_dto.dart';
import '../../../_core/utils/error_utils.dart';
import '../../../_core/utils/my_http.dart';
import '../models/member.dart';
import '../dtos/member_register_request.dto.dart';
import '../dtos/member_register_response.dto.dart';
import '../dtos/id_check_response.dto.dart';

class RegistrationRepository {
  final Dio _dio = dio;

  RegistrationRepository() {
    // Global dio instance might already have interceptors.
    // Adding it here might be redundant but ensures it if not globally set.
    if (!_dio.interceptors
        .any((interceptor) => interceptor is LogInterceptor)) {
      _dio.interceptors
          .add(LogInterceptor(requestBody: true, responseBody: true));
    }
  }

  Future<bool> checkIdAvailability(String loginId) async {
    try {
      final dioResponse = await _dio.get(
        '/members/check-id',
        queryParameters: {'loginId': loginId},
      );
      final apiResponse = ApiResponseDto<IdCheckResponseDataDto>.fromJson(
        dioResponse.data as Map<String, dynamic>,
        fromJsonT: IdCheckResponseDataDto.fromJson,
      );
      if (apiResponse.success && apiResponse.response != null) {
        return apiResponse.response!.available;
      } else if (!apiResponse.success && apiResponse.error != null) {
        throw Exception(
            apiResponse.error!.message ?? '아이디 중복 확인 중 알 수 없는 서버 오류');
      } else {
        throw Exception('아이디 중복 확인 중 알 수 없는 오류 (서버 응답 형식 확인 필요)');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e,
          '[RegistrationRepository CheckIdAvailability Error - DioException]');
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print(
          '[RegistrationRepository CheckIdAvailability Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }

  Future<Member?> register(Member memberToRegister) async {
    final requestDto = MemberRegisterRequestDto.fromModel(memberToRegister);
    try {
      final dioResponse = await _dio.post(
        '/members/register',
        data: requestDto.toJson(),
      );
      final apiResponse =
          ApiResponseDto<MemberRegisterResponseDataDto>.fromJson(
        dioResponse.data as Map<String, dynamic>,
        fromJsonT: MemberRegisterResponseDataDto.fromJson,
      );
      if (apiResponse.success && apiResponse.response != null) {
        return apiResponse.response!.toMember();
      } else if (!apiResponse.success && apiResponse.error != null) {
        throw Exception(
            apiResponse.error!.message ?? '회원가입 처리 중 알 수 없는 서버 오류가 발생했습니다.');
      } else {
        throw Exception('알 수 없는 이유로 회원가입에 실패했습니다. (서버 응답 형식 확인 필요)');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(
          e, '[RegistrationRepository Register Error - DioException]');
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print(
          '[RegistrationRepository Register Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }

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
