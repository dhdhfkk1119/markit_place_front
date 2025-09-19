import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../_core/utils/my_http.dart';

const String Url = baseUrl;
const FlutterSecureStorage _storage = FlutterSecureStorage();

class ProductListRepository {
  Future<Map<String, dynamic>> productList() async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다');
    }

    try {
      final response = await dio.get(
        Url + '/items',
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
      print('아이템 상품 정보 : ${response.statusCode}');
      print('아이템 상품 리스폰스 데이터: ${response.data}'); // Log the raw response data

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
