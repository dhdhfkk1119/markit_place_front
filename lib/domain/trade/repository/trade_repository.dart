import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../_core/utils/my_http.dart';

// 거래 관련 API를 담당하는 레포지토리
class TradeRepository {
  final Logger logger = Logger();

  // 구매 내역 조회 API
  // 로그인한 사용자의 구매 내역을 페이지 단위로 조회
  Future<Map<String, dynamic>> tradeList(
      {int page = 0, int size = 10, String sort = 'createdAt,desc'}) async {
    final response = await dio.get(
      '/v1/trades/purchases', // 중복된 /api/ 제거 (서버에서 자동으로 api/를 추가하기 때문)
      queryParameters: {
        'page': page,
        'size': size,
        'sort': sort,
      },
    );
    final data = response.data as Map<String, dynamic>?; // 전체 응답 데이터

    logger.d("서버 응답 데이터:", data); // 디버깅을 위해 응답 데이터 로깅

    // 서버는 실제 데이터를 'response' 키에 담아 반환함
    if (data == null || data['response'] == null) {
      logger.e('구매내역 응답 데이터가 null입니다.', response);
      // 빈 데이터 반환 (에러 방지)
      return {
        'content': <dynamic>[],
        'last': true,
        'page': page,
      };
    }
    final responseMap =
        data['response'] as Map<String, dynamic>?; // 실제 구매내역 데이터 (수정됨)
    final content =
        responseMap?['content'] as List<dynamic>? ?? <dynamic>[]; // 구매내역 리스트
    final last = responseMap?['last'] as bool? ?? true; // 마지막 페이지 여부
    final pageNum =
        responseMap?['pageable']?['pageNumber'] as int? ?? page; // 현재 페이지 번호
    // 구매내역 리스트, 페이지 정보, 마지막 페이지 여부 반환
    return {
      'content': content,
      'last': last,
      'page': pageNum,
    };
  }

  // 거래 생성 (구매하기) API
  // 상품 ID를 받아 거래를 생성
  Future<void> buyItem({
    required int productId,
  }) async {
    await dio.post(
      '/v1/trades', // 중복된 /api/ 제거 (서버에서 자동으로 api/를 추가하기 때문)
      data: {'itemId': productId}, // 구매할 상품 ID
    );
  }

  // 단건 구매 카드 조회 (특정 거래 갱신)
  Future<Map<String, dynamic>> getTradeById(int tradeId) async {
    final response = await dio.get('/v1/trades/$tradeId'); // 중복된 /api/ 제거
    final data = response.data as Map<String, dynamic>?;
    if (data == null || data['response'] == null) {
      // 'data' -> 'response'로 변경
      logger.e('단건 거래 조회 응답이 비정상입니다.', response);
      return {};
    }
    return data['response'] as Map<String, dynamic>; // 'data' -> 'response'로 변경
  }
}
