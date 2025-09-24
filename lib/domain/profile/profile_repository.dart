// D:/workspace-flutter/markit_place_front/lib/domain/profile/profile_repository.dart
import 'package:dio/dio.dart'; // Dio 사용
import 'package:flutter/foundation.dart'; // debugPrint 사용

import '../../_core/dtos/api_response_dto.dart';
import '../../_core/dtos/error_dto.dart';
import '../../_core/utils/error_utils.dart';
import '../../_core/utils/my_http.dart'; // 전역 dio 인스턴스 사용
import '../members/dtos/my_profile_response_data_dto.dart';
import '../members/dtos/profile_update_request_dto.dart';
import '../members/models/session_user.dart'; // SessionUser 사용

class ProfileRepository {
  final Dio _dio = dio;

  ProfileRepository();

  Future<SessionUser?> getMyProfile() async {
    try {
      final dioResponse = await _dio.get('/members/me');
      debugPrint(
          '[ProfileRepository GetMyProfile] Server Response Data: ${dioResponse.data}'); // 응답 로깅 추가
      final apiResponse = ApiResponseDto<MyProfileResponseDataDto>.fromJson(
        dioResponse.data,
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
      debugPrint(
          '[ProfileRepository GetMyProfile Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }

  Future<SessionUser?> updateMyProfile(
      ProfileUpdateRequestDto requestDto) async {
    try {
      final jsonData = requestDto.toJson();
      debugPrint(
          '[ProfileRepository UpdateMyProfile] Request JSON Data: $jsonData'); // 요청 로깅 추가

      if (jsonData.isEmpty) {
        // return await getMyProfile();
      }

      final dioResponse = await _dio.patch(
        '/members/me',
        data: jsonData,
      );
      // 서버 응답 로깅 추가
      debugPrint(
          '[ProfileRepository UpdateMyProfile] Server Response Data: ${dioResponse.data}');

      final apiResponse = ApiResponseDto<MyProfileResponseDataDto>.fromJson(
        dioResponse.data,
        fromJsonT: MyProfileResponseDataDto.fromJson,
      );

      if (apiResponse.success && apiResponse.response != null) {
        return apiResponse.response!.toSessionUser();
      } else if (!apiResponse.success && apiResponse.error != null) {
        // 여기서 apiResponse.error.message가 null일 경우 문제가 발생할 수 있음 (이미 ?? 처리 되어있지만, 타입 캐스팅은 다른 문제)
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
      // 여기서 e의 실제 타입과 메시지를 확인하는 것이 중요
      final errorMessage = extractErrorMessage(e);
      debugPrint(
          '[ProfileRepository UpdateMyProfile Error - General] Original Exception: ${e.runtimeType} - ${e.toString()}');
      debugPrint(
          '[ProfileRepository UpdateMyProfile Error - General] ExtractedMessage: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<MyProfileResponseDataDto> getFindByUser(int id) async {
    try {
      final dioResponse = await _dio.get('/members/$id');
      debugPrint(
          '[ProfileRepository GetFindByUser] Server Response Data for ID $id: ${dioResponse.data}'); // 응답 로깅 추가
      final apiResponse = ApiResponseDto<MyProfileResponseDataDto>.fromJson(
        dioResponse.data,
        fromJsonT: MyProfileResponseDataDto.fromJson,
      );
      if (apiResponse.success && apiResponse.response != null) {
        return apiResponse.response!;
      } else if (!apiResponse.success && apiResponse.error != null) {
        throw Exception(
            apiResponse.error!.message ?? 'ID로 사용자 프로필 조회 중 알 수 없는 서버 오류');
      } else {
        throw Exception('ID로 사용자 프로필 조회 중 알 수 없는 오류 (서버 응답 형식 확인 필요)');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(
          e, '[ProfileRepository GetFindByUser Error - DioException]');
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      debugPrint(
          '[ProfileRepository GetFindByUser Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }

  String _handleDioError(DioException e, String logPrefix) {
    String finalErrorMessage;
    ErrorDto? parsedErrorDto;
    // DioException 발생 시 응답 데이터 로깅
    debugPrint('$logPrefix - DioException Response Data: ${e.response?.data}');

    if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
      final responseData = e.response!.data as Map<String, dynamic>;
      if (responseData.containsKey('error') &&
          responseData['error'] != null &&
          responseData['error'] is Map<String, dynamic>) {
        try {
          parsedErrorDto =
              ErrorDto.fromJson(responseData['error'] as Map<String, dynamic>);
        } catch (parseError) {
          debugPrint(
              '$logPrefix - Failed to parse ErrorDto from responseData.error: $parseError');
        }
      }
    }

    if (parsedErrorDto?.message != null &&
        parsedErrorDto!.message!.isNotEmpty) {
      finalErrorMessage = parsedErrorDto.message!;
    } else {
      String dioErrorMessage = e.message ?? '';
      if (dioErrorMessage.isEmpty &&
          e.response?.statusMessage != null &&
          e.response!.statusMessage!.isNotEmpty) {
        dioErrorMessage = e.response!.statusMessage!;
      }
      finalErrorMessage = extractErrorMessage(e);
      if (finalErrorMessage.toLowerCase().contains('exception') &&
          dioErrorMessage.isNotEmpty &&
          !dioErrorMessage.toLowerCase().contains('exception')) {
        finalErrorMessage = dioErrorMessage;
      }
    }

    debugPrint(
        '$logPrefix Final Message: $finalErrorMessage (Dio Status: ${e.response?.statusCode})');
    if (parsedErrorDto != null) {
      debugPrint(
          '$logPrefix Parsed ErrorDto: Code: ${parsedErrorDto.code}, Field: ${parsedErrorDto.field}, Status: ${parsedErrorDto.status}');
    }
    return finalErrorMessage;
  }
}
