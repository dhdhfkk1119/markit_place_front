import 'package:dio/dio.dart';

class MannerPraiseRepository {
  final Dio _dio;

  MannerPraiseRepository(this._dio);

  Future<void> praiseManner(int sellerId, String praiseType) async {
    try {
      await _dio.patch(
        'http://localhost:8080/api/v1/praise',
        data: {
          'sellerId': sellerId,
          'praiseType': praiseType,
        },
      );
      print('매너 칭찬 요청 성공');
    } catch (e) {
      print('매너 칭찬 요청 실패: $e');
      throw Exception('매너 칭찬 요청에 실패했습니다.');
    }
  }
}
