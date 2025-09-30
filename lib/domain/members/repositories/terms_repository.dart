import 'package:dio/dio.dart';
import '../../../_core/dtos/api_response_dto.dart';
import '../../../_core/dtos/error_dto.dart';
import '../../../_core/utils/error_utils.dart';
import '../models/term.dart';

class TermsRepository {
  final Dio _dio;

  // 생성자에서 Dio 인스턴스를 반드시 받도록 수정합니다.
  // 이제 이 클래스는 자체적으로 Dio를 생성할 수 없습니다.
  TermsRepository({required Dio dio}) : _dio = dio;

  Future<List<Term>> fetchTermsList() async {
    try {
      // baseUrl이 적용된 dio 인스턴스를 사용하므로, 상대 경로만 작성합니다.
      final response = await _dio.get('/terms');

      // onResponse 인터셉터에서 success:false 처리를 하므로, 여기서는 성공 케이스만 다룹니다.
      final apiResponse = ApiResponseDto<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
      );

      final List<dynamic> dynamicList = apiResponse.response!;
      return dynamicList
          .map((item) => Term.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // DioException 발생 시, 인터셉터에서 가공된 에러 메시지를 사용합니다.
      throw Exception(extractErrorMessage(e));
    } catch (e) {
      // 기타 예외 처리
      throw Exception('알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
