import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../_core/utils/my_http.dart';
import '../../../presentation/pages/index_stack_page/product/list_page/product_list_page.dart';
import '../dtos/product_search_dto.dart';
import '../models/product_list.dart';

const String Url = baseUrl;
const FlutterSecureStorage _storage = FlutterSecureStorage();

class ProductListRepository {
  // 게시물 검색
  Future<ProductListPages> getProducts(ProductSearchDTO searchDto) async {
    try {
      final queryParameters = searchDto.toMap();

      final response =
          await dio.get('/items', queryParameters: queryParameters);

      if (response.statusCode == 200) {
        // 3. 서버 응답(JSON)을 ProductList 객체로 파싱!
        // 서버 응답의 'data' 필드가 상품 리스트라고 가정
        print(response.data);
        final List<dynamic> responseData = response.data['content'] ?? [];
        final bool isLast = response.data['last'];

        final List<ProductList> productList = responseData
            .map((item) => ProductList.fromJson(item as Map<String, dynamic>))
            .toList();

        return ProductListPages(productList: productList, isLastPage: isLast);
      } else {
        // Dio는 2xx 상태 코드가 아니면 자동으로 에러를 던져주므로, 이 부분은 DioError에서 처리됨.
        throw Exception('Failed to load products');
      }
    } on DioError catch (e) {
      // 4. DioError를 특정해서 더 자세한 에러 처리가 가능
      // e.response?.data 에 서버가 보낸 에러 메시지가 담겨 있을 수 있음
      throw Exception('상품 목록을 불러오는데 실패했습니다: ${e.message}');
    } catch (e) {
      throw Exception('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // 게시물 삭제하기
  Future<bool> productDelete(int id) async {
    try {
      final response = await dio.delete('/items/$id');

      // 200 OK 또는 204 No Content 일 때 성공
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true; // 성공
      } else {
        return false; // 그 외의 경우는 실패로 간주
      }
    } on DioError catch (e) {
      // 서버에서 404 (Not Found) 같은 응답을 줬을 때 여기서 처리 가능
      print('상품 삭제 실패: ${e.response?.data}');
      return false;
    } catch (e) {
      print('상품 삭제 중 알 수 없는 에러: $e');
      return false;
    }
  }
}
