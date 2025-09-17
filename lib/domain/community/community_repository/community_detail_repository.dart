import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

class CommunityDetailRepository {
  final Dio _dio = dio;

  Future<Map<String, dynamic>> communityDetail(
      {required int communityId}) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다.');
    }
    try {
      final response = await _dio.get(
        '/community/posts/${communityId}',
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      print('커뮤니티 글 상세 정보 : ${response.statusCode}');
      print('커뮤니티 글 상세 데이터: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('커뮤니티 글 상세보기 실패 : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('서버와 연결 실패: $e');
    }
  }
}
