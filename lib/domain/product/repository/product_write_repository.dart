import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/domain/product/dtos/product_write_dto.dart';

String Url = baseUrl;
const FlutterSecureStorage _storage = FlutterSecureStorage();

class ProductWriteRepository {
  Future<void> productWrite(
    ProductWriteDto dto,
    int memberId,
    List<String> base64Images,
  ) async {
    final token = await _storage.read(key: "accessToken");
    print(">>> ProductWrite 요청 시작"); // 이거 안 찍히면 호출 자체 문제

    try {
      // 요청 데이터 로그
      print("=== ProductWrite Request ===");
      print("memberId: $memberId");
      print("title: ${dto.title}");
      print("content: ${dto.content}");
      print("price: ${dto.price}");
      print("categoryId: ${dto.itemCategoryId}");
      print("images count: ${base64Images.length}");
      print("===========================");

      final response = await dio.post(
        '$Url/items',
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
        data: {
          "itemCategoryId": dto.itemCategoryId,
          "memberAddressId": memberId,
          "title": dto.title,
          "content": dto.content,
          "price": dto.price,
          "base64Images": base64Images,
        },
      );

      // 서버 응답 로그
      print("=== ProductWrite Response ===");
      print(response.statusCode);
      print(response.data);
      print("=============================");
    } catch (e) {
      print("=== ProductWrite ERROR ===");
      print(e);
      print("==========================");
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
