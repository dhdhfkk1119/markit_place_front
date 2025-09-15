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
        '/members/register', // 수정된 경로
        data: requestDto.toJson(),
      );

      // ApiResponseDto의 제네릭 타입을 명시적으로 지정
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
      final errorMessage = extractErrorMessage(e);
      print('[Register Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> login(String loginId, String password) async {
    try {
      final dioResponse = await _dio.post(
        '/members/login', // 수정된 경로
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

  // 회원가입용 이메일 인증 코드 발송 요청
  Future<void> requestEmailVerification(String email) async {
    try {
      final dioResponse = await _dio.post(
        '/email/register/send-code',
        data: {'email': email},
      );

      // 서버 응답이 String이므로 ApiResponseDto<String>으로 파싱
      final apiResponse = ApiResponseDto<String>.fromJson(
        dioResponse.data as Map<String, dynamic>,
      );

      if (apiResponse.success) {
        print('인증 코드 발송 요청 성공: $email, 응답 메시지: ${apiResponse.response}');
        // 성공 시 특별한 반환 값 없음 (void)
      } else {
        throw Exception(apiResponse.error?.message ?? '인증 코드 발송에 실패했습니다.');
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
                '[RequestEmailVerification Error - DioException] Failed to parse ErrorDto: $parseError');
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
          '[RequestEmailVerification Error - DioException] Final Message: $finalErrorMessage (Dio Status: ${e.response?.statusCode})');
      if (parsedErrorDto != null) {
        print(
            '[RequestEmailVerification Error - DioException] Parsed ErrorDto: Code: ${parsedErrorDto.code}, Field: ${parsedErrorDto.field}, Status: ${parsedErrorDto.status}');
      }
      throw Exception(finalErrorMessage);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print('[RequestEmailVerification Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }

  // 회원가입용 이메일 인증 코드 확인 요청
  Future<bool> confirmEmailVerification(String email, String code) async {
    try {
      final dioResponse = await _dio.post(
        '/email/register/confirm-code',
        data: {'email': email, 'code': code},
      );

      // 서버 응답이 String이므로 ApiResponseDto<String>으로 파싱
      final apiResponse = ApiResponseDto<String>.fromJson(
        dioResponse.data as Map<String, dynamic>,
      );

      if (apiResponse.success) {
        print('이메일 인증 성공: $email, 응답 메시지: ${apiResponse.response}');
        return true;
      } else {
        // API 호출은 성공했으나 비즈니스 로직상 실패 (예: 코드가 틀림)
        throw Exception(apiResponse.error?.message ?? '인증 코드 확인에 실패했습니다.');
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
                '[ConfirmEmailVerification Error - DioException] Failed to parse ErrorDto: $parseError');
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
          '[ConfirmEmailVerification Error - DioException] Final Message: $finalErrorMessage (Dio Status: ${e.response?.statusCode})');
      if (parsedErrorDto != null) {
        print(
            '[ConfirmEmailVerification Error - DioException] Parsed ErrorDto: Code: ${parsedErrorDto.code}, Field: ${parsedErrorDto.field}, Status: ${parsedErrorDto.status}');
      }
      throw Exception(finalErrorMessage); // 여기서 false를 반환하는 대신 예외를 던짐
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print('[ConfirmEmailVerification Error - General] $errorMessage ($e)');
      throw Exception(errorMessage); // 여기서 false를 반환하는 대신 예외를 던짐
    }
  }
}
