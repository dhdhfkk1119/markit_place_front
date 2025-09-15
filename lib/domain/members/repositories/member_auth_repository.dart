import 'package:dio/dio.dart';
import 'package:markit_place_front/_core/dtos/api_response_dto.dart';
import 'package:markit_place_front/_core/dtos/error_dto.dart'; // ErrorDto 임포트 추가
import 'package:markit_place_front/_core/utils/error_utils.dart';
import 'package:markit_place_front/domain/members/models/member.dart';
import 'package:markit_place_front/domain/members/dtos/member_register_request.dto.dart';
import 'package:markit_place_front/domain/members/dtos/member_register_response.dto.dart';
import 'package:markit_place_front/domain/members/dtos/login_response.dto.dart';

class MemberAuthRepository {
  final Dio _dio;
  final String _baseUrl = "http://192.168.0.128:8080/api";

  MemberAuthRepository() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.interceptors
        .add(LogInterceptor(requestBody: true, responseBody: true));
  }

  Future<Member?> register(Member memberToRegister) async {
    final requestDto = MemberRegisterRequestDto.fromModel(memberToRegister);

    try {
      final dioResponse = await _dio.post(
        '/register',
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
                '[Register Error - DioException] Failed to parse ErrorDto: $parseError');
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
          '[Register Error - DioException] Final Message: $finalErrorMessage (Dio Status: ${e.response?.statusCode})');
      if (parsedErrorDto != null) {
        print(
            '[Register Error - DioException] Parsed ErrorDto: Code: ${parsedErrorDto.code}, Field: ${parsedErrorDto.field}, Status: ${parsedErrorDto.status}');
      }
      throw Exception(finalErrorMessage);
    } catch (e) {
      // DioException 외의 예외 (네트워크 연결 자체 실패 등은 여기에 해당 안될 수 있음, DioException의 type으로 구분)
      final errorMessage = extractErrorMessage(e);
      print('[Register Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> login(String loginId, String password) async {
    try {
      final dioResponse = await _dio.post(
        '/login',
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
                '[Login Error - DioException] Failed to parse ErrorDto: $parseError');
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
          '[Login Error - DioException] Final Message: $finalErrorMessage (Dio Status: ${e.response?.statusCode})');
      if (parsedErrorDto != null) {
        print(
            '[Login Error - DioException] Parsed ErrorDto: Code: ${parsedErrorDto.code}, Field: ${parsedErrorDto.field}, Status: ${parsedErrorDto.status}');
      }
      throw Exception(finalErrorMessage);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print('[Login Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }
}
