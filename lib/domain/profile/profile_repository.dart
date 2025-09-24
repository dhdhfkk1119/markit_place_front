// D:/workspace-flutter/markit_place_front/lib/domain/profile/profile_repository.dart
import 'package:dio/dio.dart'; // Dio 사용
import '../../_core/dtos/api_response_dto.dart';
import '../../_core/dtos/error_dto.dart';
import '../../_core/utils/error_utils.dart';
import '../../_core/utils/my_http.dart'; // 전역 dio 인스턴스 사용
import '../members/models/session_user.dart'; // SessionUser 사용
// members 도메인의 DTO를 직접 참조. ProfileUpdateRequestDto는 profile_dto.dart의 ProfileEditRequestDto 역할 대체
import '../members/dtos/profile_update_request_dto.dart';
import '../members/dtos/my_profile_response_data_dto.dart'; // getMyProfile, updateMyProfile, getFindByUser 응답용

// 기존 profile_dto.dart (ProfileEditRequestDto, ProfileEditResponseDto)는 ProfileUpdateRequestDto 등으로 대체됨.
// import 'profile_dto.dart'; // 더 이상 직접 사용하지 않을 가능성이 높음

class ProfileRepository {
  final Dio _dio = dio; // my_http.dart의 전역 dio 인스턴스 사용

  ProfileRepository();

  Future<SessionUser?> getMyProfile() async {
    try {
      final dioResponse = await _dio.get('/members/me');
      // dioResponse.data가 이미 Map<String, dynamic>으로 변환되어 있다고 가정 (Dio 기본 동작)
      final apiResponse = ApiResponseDto<MyProfileResponseDataDto>.fromJson(
        dioResponse.data, // Map<String, dynamic> 타입이어야 함
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
        dioResponse.data,
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

  Future<MyProfileResponseDataDto> getFindByUser(int id) async {
    try {
      // Dio 인터셉터가 인증 헤더를 처리한다고 가정
      final dioResponse = await _dio.get('/members/$id');

      // 서버 응답이 ApiResponseDto 형태인지, 아니면 직접 MyProfileResponseDataDto 데이터인지 확인 필요
      // 여기서는 ApiResponseDto<MyProfileResponseDataDto>를 기대하고 처리
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
      print(
          '[ProfileRepository GetFindByUser Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }

  String _handleDioError(DioException e, String logPrefix) {
    String finalErrorMessage;
    ErrorDto? parsedErrorDto;
    if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
      final responseData = e.response!.data as Map<String, dynamic>;
      // ApiResponseDto의 error 필드를 먼저 확인
      if (responseData.containsKey('error') &&
          responseData['error'] != null &&
          responseData['error'] is Map<String, dynamic>) {
        try {
          parsedErrorDto =
              ErrorDto.fromJson(responseData['error'] as Map<String, dynamic>);
        } catch (parseError) {
          print(
              '$logPrefix - Failed to parse ErrorDto from responseData.error: $parseError');
        }
      }
      // 만약 responseData 자체가 ErrorDto 형태일 수 있다면 (보통은 ApiResponseDto로 감싸짐)
      // else if (ErrorDto.isErrorDtoMap(responseData)) { // ErrorDto에 이런 static 메소드가 있다고 가정
      //   try {
      //     parsedErrorDto = ErrorDto.fromJson(responseData);
      //   } catch (parseError) {
      //     print('$logPrefix - Failed to parse ErrorDto from responseData: $parseError');
      //   }
      // }
    }

    if (parsedErrorDto?.message != null &&
        parsedErrorDto!.message!.isNotEmpty) {
      finalErrorMessage = parsedErrorDto.message!;
    } else {
      // Dio 오류 메시지 또는 기본 오류 메시지 사용
      finalErrorMessage = e.message ?? extractErrorMessage(e);
      if (e.response?.statusMessage != null &&
          e.response!.statusMessage!.isNotEmpty) {
        finalErrorMessage =
            '${e.response!.statusMessage!} ($finalErrorMessage)';
      }
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
