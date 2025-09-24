import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../_core/utils/my_http.dart';

final FlutterSecureStorage _storage = FlutterSecureStorage();

class ProductFavoriteRepository {
  Future<Map<String, dynamic>> productFavorite(
      {int page = 0, int size = 10}) async {
    final token = await _storage.read(key: "accessToken");

    print("찜하기 내역 Token: $token");
    try {
      final response = await dio.get("/items/favorites/me",
          queryParameters: {'page': page, 'size': size},
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ));
      if (response.statusCode == 200) {
        print("좋아요 목록을 가져옴 : ${response.data['content']}");
        return response.data;
      }
      throw Exception('Failed to connect to the server');
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }
}
