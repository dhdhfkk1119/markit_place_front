import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../_core/utils/my_http.dart';
import '../models/product_detail.dart';
import '../models/product_favorites.dart';

const String Url = baseUrl;
const FlutterSecureStorage _storage = FlutterSecureStorage();

class ProductDetailRepository {
  // 상품 상세 정보
  Future<ProductDetail> productDetail({required int itemId}) async {
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
      print("상품에 대한 상세 정보 : ${response.data}");

      if (response.statusCode == 200) {
        print("상품에 대한 상세 정보 : ${response.data}");

        return ProductDetail.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // 상품 좋아요 버튼
  Future<ProductFavorites> productFavorite({required int itemId}) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다');
    }

    try {
      final response = await dio.post(
        '/items/${itemId}/favorite',
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
      print("좋아요 서버에 연결됨 : ${response.data}");
      if (response.statusCode == 200) {
        return ProductFavorites.fromJson(response.data);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}

final productDetailRepositoryProvider = Provider((ref) {
  return ProductDetailRepository();
});
