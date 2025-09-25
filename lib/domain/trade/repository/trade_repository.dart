import 'package:dio/dio.dart';

import '../../../_core/utils/my_http.dart';

class TradeRepository {
  // 구매 내역 조회 API
  Future<Map<String, dynamic>> tradeList(
      {int page = 0, int size = 10, String sort = 'createdAt,desc'}) async {
    try {
      // 새 API 명세에 따라 URL을 '/api/v1/trades/purchases'로 수정
      final response = await dio.get(
        '/api/v1/trades/purchases',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // 실제 데이터는 'data' 필드 안에 있으므로, 이를 추출하여 반환
        return response.data['data'];
      } else {
        // DioException으로 변환되어 인터셉터에서 처리될 것임
        throw Exception('구매내역 가져오기 실패');
      }
    } catch (e) {
      rethrow; // 에러를 그대로 상위로 전달하여 인터셉터가 처리하도록 함
    }
  }

  // 거래 생성 (구매하기) API
  Future<void> buyItem({
    required int productId,
  }) async {
    try {
      // 새 API 명세에 따라 URL을 '/api/v1/trades'로 수정하고,
      // 상품 ID를 요청 본문(body)에 담아 전송
      final response = await dio.post(
        '/api/v1/trades',
        data: {'itemId': productId},
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        // DioException으로 변환되어 인터셉터에서 처리될 것임
        throw Exception('구매하기 실패');
      }
    } catch (e) {
      rethrow; // 에러를 그대로 상위로 전달하여 인터셉터가 처리하도록 함
    }
  }
}
