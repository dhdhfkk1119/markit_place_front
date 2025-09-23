import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../_core/utils/my_http.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

class SalesRepository {
  Future<Map<String, dynamic>> salesList({int page = 0, int size = 10}) async {
    final token = await _storage.read(key: "accessToken");
    print("상품 거내 내역 Token: $token");
    try {
      final response = await dio.get(
        '/items/sales',
        queryParameters: {
          'page': page,
          'size': size,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      print("statusCode: ${response.statusCode}");
      print("response: ${response.data}");
      if (response.statusCode == 200) {
        print("판매 목록을 가져옴 : ${response.data['content']}");
        return response.data;
      }
      throw Exception('Failed to connect to the server');
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }
}
