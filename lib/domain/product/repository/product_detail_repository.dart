import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:markit_place_front/_core/utils/my_http.dart';

const String baseUrl = "http://192.168.0.128:8080";
const FlutterSecureStorage _storage = FlutterSecureStorage();

class ProductDetailRepository {
  Future<Map<String, dynamic>> productDetail({required int itemId}) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다');
    }

    try {
      final response = await dio.get(
        baseUrl + '/api/items/${itemId}',
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
      print('[상세]아이템 상품 상세 정보 : ${response.statusCode}');
      print('[상세]아이템 상품 상세 데이터: ${response.data}'); // Log the raw response data

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
