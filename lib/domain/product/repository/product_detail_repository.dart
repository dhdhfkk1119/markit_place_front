import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../_core/utils/my_http.dart';

const String Url = baseUrl;
const FlutterSecureStorage _storage = FlutterSecureStorage();

class ProductDetailRepository {
  Future<Map<String, dynamic>> productDetail({required int itemId}) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다');
    }

    try {
      final response = await dio.get(
        baseUrl + '/items/${itemId}',
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
      print('[상세]아이템 상품 상세 정보 : ${response.statusCode}');
      print('[상세]아이템 상품 유저의 이미지 정보: ${response.data['sellerProfileUrl']}');

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
