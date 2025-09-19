import 'package:dio/dio.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/domain/community/community_dto/community_category_dto.dart';
import 'package:dio/dio.dart';


class CommunityCategoryRepository {
  final Dio dio = Dio();

  Future<List<CommunityCategoryDTO>> getCategories() async {
    try {
      final response = await dio.get("$baseUrl/community/categories");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['data'];
        return jsonList
            .map((json) => CommunityCategoryDTO.fromJson(json))
            .toList();
      } else {
        throw Exception("Failed to load categories. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to load categories: $e");
    }
  }
}