// D:/workspace-flutter/markit_place_front/lib/domain/members/repositories/profile_repository.dart
import 'package:dio/dio.dart';
import '../../../_core/dtos/api_response_dto.dart';
import '../../../_core/dtos/error_dto.dart';
import '../../../_core/utils/error_utils.dart';
import '../../../_core/utils/my_http.dart';
import '../models/session_user.dart';
import '../dtos/profile_update_request_dto.dart';
import '../dtos/my_profile_response_data_dto.dart';

class ProfileRepository {
  final Dio _dio = dio;

  ProfileRepository();

  Future<SessionUser?> getMyProfile() async {
    try {
      final dioResponse = await _dio.get('/members/me');
      final apiResponse = ApiResponseDto<MyProfileResponseDataDto>.fromJson(
        dioResponse.data as Map<String, dynamic>,
        fromJsonT: MyProfileResponseDataDto.fromJson,
      );
      if (apiResponse.success && apiResponse.response != null) {
        return apiResponse.response!.toSessionUser();
      } else if (!apiResponse.success && apiResponse.error != null) {
        throw Exception(apiResponse.error!.message ?? '내 정보 조회 중 알 수 없는 서버 오류');
      } else {
        throw Exception('내 정보 조회 중 알 수 없는 오류 (서버 응답 형식 확인 필요)');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(
          e, '[ProfileRepository GetMyProfile Error - DioException]');
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print(
          '[ProfileRepository GetMyProfile Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }

  Future<SessionUser?> updateMyProfile(
      ProfileUpdateRequestDto requestDto) async {
    try {
      final dioResponse = await _dio.patch(
        '/members/me',
        data: requestDto.toJson(),
      );
      final apiResponse = ApiResponseDto<MyProfileResponseDataDto>.fromJson(
        dioResponse.data as Map<String, dynamic>,
        fromJsonT: MyProfileResponseDataDto.fromJson,
      );
      if (apiResponse.success && apiResponse.response != null) {
        return apiResponse.response!.toSessionUser();
      } else if (!apiResponse.success && apiResponse.error != null) {
        throw Exception(
            apiResponse.error!.message ?? '프로필 업데이트 중 알 수 없는 서버 오류');
      } else {
        throw Exception('프로필 업데이트 중 알 수 없는 오류 (서버 응답 형식 확인 필요)');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(
          e, '[ProfileRepository UpdateMyProfile Error - DioException]');
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print(
          '[ProfileRepository UpdateMyProfile Error - General] $errorMessage ($e)');
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

  // Future<MyProfileResponseDataDto> getFindById(int userId) async {}
}
