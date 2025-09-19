import 'package:dio/dio.dart';
import '../../../_core/utils/my_http.dart';

// String baseUrl = "http://192.168.0.128:8080/api";

class CommunityListRepository {
  final Dio _dio = dio;
  Future<Map<String, dynamic>> communityList() async {
    try {
      print("Repository: API 요청 시작: ${baseUrl}/community/posts");

      final response = await _dio.get('/community/posts');

      print("커뮤니티 목록 정보: ${response.statusCode}");
      print("커뮤니티 목록 서버 데이터: ${response.data}");

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("커뮤니티 글 목록보기 실패 : ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("서버와 연결 실패: $e");
    }
  }
}
