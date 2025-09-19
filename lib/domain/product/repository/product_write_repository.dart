import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../_core/utils/my_http.dart';
import '../dtos/product_write_dto.dart';

String Url = baseUrl;
const FlutterSecureStorage _storage = FlutterSecureStorage();

class ProductWriteRepository {
  Future<void> productWrite(
    ProductWriteDto dto,
    int memberId,
    List<String> base64Images,
  ) async {
    final token = await _storage.read(key: "accessToken");

    try {
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
      print("상품 등록 리스트 : ${response}");
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
