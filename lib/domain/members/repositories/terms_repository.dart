import 'package:dio/dio.dart';
import '../../../_core/dtos/api_response_dto.dart';
import '../../../_core/dtos/error_dto.dart'; // ErrorDto 임포트 추가
import '../../../_core/utils/error_utils.dart';
import '../models/term.dart';

class TermsRepository {
  final Dio _dio;

  TermsRepository({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: 'http://192.168.0.128:8080')) {
    // LogInterceptor를 TermsRepository에도 추가할 수 있습니다 (선택 사항).
    // _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  Future<List<Term>> fetchTermsList() async {
    try {
      final response = await _dio.get('/api/terms');

      final apiResponse = ApiResponseDto<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.response != null) {
        final List<dynamic> dynamicList = apiResponse.response!;
        return dynamicList
            .map((item) => Term.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (!apiResponse.success && apiResponse.error != null) {
        throw Exception(
            apiResponse.error!.message ?? '약관 목록을 불러오는데 실패했습니다. (서버 응답)');
      } else {
        throw Exception('알 수 없는 이유로 약관 목록을 불러오지 못했습니다.');
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
                '[TermsRepository Error - DioException] Failed to parse ErrorDto: $parseError');
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
          '[TermsRepository Error - DioException] Final Message: $finalErrorMessage (Dio Status: ${e.response?.statusCode})');
      if (parsedErrorDto != null) {
        print(
            '[TermsRepository Error - DioException] Parsed ErrorDto: Code: ${parsedErrorDto.code}, Field: ${parsedErrorDto.field}, Status: ${parsedErrorDto.status}');
      }
      throw Exception(finalErrorMessage);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print('[TermsRepository Error - General] $errorMessage ($e)');
      throw Exception(errorMessage);
    }
  }
}
