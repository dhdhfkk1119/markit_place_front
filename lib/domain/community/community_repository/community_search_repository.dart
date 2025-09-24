import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../_core/utils/my_http.dart';
import '../community_dto/community_list_dto.dart';

class CommunitySearchRepository {
  final Dio _dio;

  CommunitySearchRepository(this._dio);




  Future<List<CommunityListDTO>> searchPosts(String keyword) async {
    try {
      final response = await _dio.post(
        "/community/posts/search",
        data: {"keyword": keyword, "categories": [], "sortType": "latest"},
      );

      if (response.data['data'] != null) {
        final List<dynamic> postList = response.data['data'];
        return postList.map((item) => CommunityListDTO.fromJson(item)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("검색 실패: ${e.response?.data['message'] ?? '알 수 없는 서버 오류가 발생했습니다.'}");
      }
      throw Exception("검색 실패: 네트워크 연결을 확인해주세요.");
    }
  }
}

final communitySearchRepositoryProvider = Provider<CommunitySearchRepository> ((ref) {
  final dio = ref.read(dioProvider);
  return CommunitySearchRepository(dio);
});