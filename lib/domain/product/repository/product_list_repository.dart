import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../_core/utils/my_http.dart';
import '../dtos/product_search_dto.dart';

const String Url = baseUrl;
const FlutterSecureStorage _storage = FlutterSecureStorage();

class ProductListRepository {
  // 게시물 검색
  Future<Map<String, dynamic>> getProducts(ProductSearchDTO searchDto) async {
    final token = await FlutterSecureStorage().read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다');
    }

    try {
      final queryParameters = searchDto.toMap(); // toMap() 메서드 호출

      final response =
          await dio.get('/items', queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // 게시물 삭제하기
  Future<void> productDelete(int id) async {
    try {
      final response = await dio.delete('/items/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 삭제 성공이니까 UI 갱신 로직 실행
        print("상품 삭제 성공");
        return;
      } else {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }
}
