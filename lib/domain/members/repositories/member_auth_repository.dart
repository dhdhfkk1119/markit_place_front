// D:/workspace-flutter/markit_place_front/lib/domain/members/repositories/member_auth_repository.dart
import 'package:dio/dio.dart';
import '../../../_core/dtos/api_response_dto.dart';
import '../../../_core/dtos/error_dto.dart';
import '../../../_core/utils/error_utils.dart';
import '../../../_core/utils/my_http.dart';
import '../models/session_user.dart';
import '../dtos/login_response.dto.dart';
// import '../dtos/access_token_response.dto.dart'; // 제거됨

class MemberAuthRepository {
  final Dio _dio = dio;

  MemberAuthRepository() {
    // Dio 인터셉터는 my_http.dart에서 전역적으로 설정되므로,
    // 개별 Repository에서 LogInterceptor를 중복으로 추가할 필요는 없습니다.
    // 만약 특정 Repository에만 적용하고 싶은 인터셉터가 있다면 여기에 추가할 수 있습니다.
    // 기존 코드에서는 LogInterceptor 추가 로직이 있었으나, my_http.dart에서 이미 처리하고 있을 가능성이 높습니다.
    // 여기서는 일단 해당 중복 추가 로직을 제거하고, 필요시 my_http.dart 설정을 확인합니다.
  }

  Future<Map<String, dynamic>> login(String loginId, String password) async {
    try {
      final dioResponse = await _dio.post(
        '/members/login',
        data: {
          'loginId': loginId,
          'password': password,
        },
      );
      final String? token = dioResponse.headers.value('Authorization');
      final apiResponse = ApiResponseDto<LoginResponseDataDto>.fromJson(
        dioResponse.data as Map<String, dynamic>,
        fromJsonT: LoginResponseDataDto.fromJson,
      );
      if (token != null &&
          token.isNotEmpty &&
          apiResponse.success &&
          apiResponse.response != null) {
        final sessionUser = apiResponse.response!.toSessionUser();
        return {
          'sessionUser': sessionUser,
          'token': token.replaceFirst('Bearer ', ''),
        };
      } else if (!apiResponse.success && apiResponse.error != null) {
        throw Exception(
            apiResponse.error!.message ?? '로그인 처리 중 알 수 없는 서버 오류가 발생했습니다.');
      } else if (token == null || token.isEmpty) {
        throw Exception('로그인 응답에 토큰이 없습니다.');
      } else {
        throw Exception('알 수 없는 이유로 로그인에 실패했습니다. (서버 응답 형식 확인 필요)');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(
          e, '[MemberAuthRepository Login Error - DioException]');
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print('[MemberAuthRepository Login Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }

  // reissueToken 메소드 전체가 제거됨

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
