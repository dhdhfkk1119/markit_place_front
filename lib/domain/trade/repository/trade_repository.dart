import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../_core/utils/my_http.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

class TradeRepository {
  Future<Map<String, dynamic>> tradeList({int page = 0, int size = 10}) async {
    final token = await _storage.read(key: "accessToken");
    print("거래 내역 Token: $token");
    try {
      final response = await dio.get(
        '/v1/trade/purchases',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        print("구매내역 가져오기 성공 : ${response.data}");
        return response.data;
      }
      throw Exception("구매내역 가져오기 실패");
    } catch (e) {
      throw Exception("구매내역 가져오기 실패");
    }
  }
}
