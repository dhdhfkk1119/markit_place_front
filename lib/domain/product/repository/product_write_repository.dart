import '../../../_core/utils/my_http.dart';
import '../dtos/product_write_dto.dart';

String Url = baseUrl;

class ProductWriteRepository {
  Future<void> productWrite(
    ProductWriteDto dto,
    int memberId,
    List<String> base64ImagUrl,
  ) async {
    try {
      final response = await dio.post(baseUrl + '/items', data: {
        "itemCategoryId": dto.itemCategoryId,
        "memberAddressId": memberId,
        "title": dto.title,
        "content": dto.content,
        "price": dto.price,
        "base64Images": base64ImagUrl,
      });

      print("정상적으로 데이터가 들어왔습니다 ${response.data}");
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
