import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../_core/utils/my_http.dart';
import '../dtos/product_write_dto.dart';
import '../models/product_list.dart';

String Url = baseUrl;
const FlutterSecureStorage _storage = FlutterSecureStorage();

class ProductWriteRepository {
  Future<void> productWrite(
    ProductWriteDto dto,
    int memberId,
    ProductLocation? tradeLocation,
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
          "tradeLocation": tradeLocation,
        },
      );
      print("상품 등록 리스트 : ${response}");
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<void> productUpdate(
    int productId,
    ProductWriteDto dto,
    int memberId,
    ProductLocation? tradeLocation,
    List<String> base64Images,
  ) async {
    final token = await _storage.read(key: "accessToken");

    try {
      final data = {
        "itemCategoryId": dto.itemCategoryId,
        "memberAddressId": memberId,
        "title": dto.title,
        "content": dto.content,
        "price": dto.price,
        "tradeLocation": tradeLocation,
      };

      // 이미지를 선택한 경우에만 base64Images 추가
      if (base64Images.isNotEmpty) {
        data["base64Images"] = base64Images;
      }

      final response = await dio.patch(
        '$Url/items/$productId',
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
        data: data,
      );

      print("상품 수정 결과 : $response");
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
