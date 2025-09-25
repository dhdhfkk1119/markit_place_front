import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../_core/utils/my_http.dart';
import '../community_dto/community_list_dto.dart';

class CommunityListRepository {
  final Dio _dio;

  CommunityListRepository(this._dio);

  Future<List<CommunityListDTO>> fetchCommunityList({int page = 0}) async {
    try {
      final response = await _dio.get(
        "/community/posts",
        queryParameters: {"page": page},
      );

      final List<dynamic> postList = response.data['response'];

      if (postList == null) {
        return [];
      }

      return postList.map((item) => CommunityListDTO.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception(
          "게시글 목록을 불러올 수 없습니다: ${e.response?.data['message'] ?? e.toString()}");
    }
  }

  Future<List<CommunityListDTO>> searchPosts(String keyword,
      {int page = 0}) async {
    try {
      final response = await _dio.post(
        "/community/posts/search",
        data: {
          "keyword": keyword,
          "categories": [],
          "sortType": "latest",
          "page": page,
          "size": 10,
        },
      );

      final List<dynamic> postList = response.data['response']['content'];

      if (postList == null) {
        return [];
      }
      return postList.map((item) => CommunityListDTO.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception(
          "검색 실패: ${e.response?.data['message'] ?? '알 수 없는 서버 오류가 발생했습니다.'}");
    }
  }
}

final communityListRepositoryProvider =
    Provider<CommunityListRepository>((ref) {
  final dio = ref.read(dioProvider);
  return CommunityListRepository(dio);
});
