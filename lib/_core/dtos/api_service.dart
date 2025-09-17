import 'package:dio/dio.dart';
import '../dtos/api_response_dto.dart';
import '../dtos/profile_response_dto.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:8080/api/v1';

  Future<ProfileResponseDto> fetchUserProfile(int memberId) async {
    try {
      final response = await _dio.get('$_baseUrl/members/$memberId/profile');

      final apiResponse = ApiResponseDto<ProfileResponseDto>.fromJson(
        response.data,
        fromJsonT: (json) => ProfileResponseDto.fromJson(json),
      );

      if (apiResponse.success) {
        if (apiResponse.response != null) {
          return apiResponse.response!;
        } else {
          throw Exception('프로필 응답 데이터가 비어있습니다.');
        }
      } else {

        throw Exception(apiResponse.error?.message ?? '알 수 없는 오류가 발생했습니다.');
      }
    } on DioException catch (e) {

      throw Exception('네트워크 오류: ${e.response?.statusCode}');
    } catch (e) {

      throw Exception('프로필 정보를 가져오는 데 실패했습니다: $e');
    }
  }
}