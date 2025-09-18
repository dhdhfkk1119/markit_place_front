import 'package:markit_place_front/_core/utils/my_http.dart';

String Url = baseUrl;

class ProductCategoryRepository {
  // 1. 메서드의 반환 타입을 Map<String, dynamic>에서 List<dynamic>으로 변경
  Future<List<dynamic>> productCategoryList() async {
    try {
      final response = await dio.get(
        baseUrl + '/item-categories',
      );
      print('아이템 카테고리 정보 : ${response.statusCode}');
      print('아이템 카테고리 데이터: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data;
        } else {
          throw Exception('API response is not a list');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
