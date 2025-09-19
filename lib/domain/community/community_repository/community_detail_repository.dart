import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../_core/utils/my_http.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

class CommunityDetailRepository {
  final Dio _dio = dio;

  Future<Map<String, dynamic>> communityDetail({required int postId}) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다.');
    }
    try {
      final response = await _dio.get(
        '/community/posts/$postId',
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      print('커뮤니티 글 상세 정보 응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.data != null && response.data['response'] != null) {
          return response.data['response'];
        } else {
          throw Exception('응답 데이터 형식이 올바르지 않습니다.');
        }
      } else {
        throw Exception('커뮤니티 글 상세보기 실패 : ${response.statusCode}');
      }
    } catch (e) {
      print('커뮤니티 글 상세 정보 요청 실패: $e');
      throw Exception('서버와 연결 실패 또는 요청 처리 중 오류: $e');
    }
  }

  // 좋아요 토글 메소드 추가
  Future<void> toggleLike({required int postId}) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다.');
    }
    try {
      final response = await _dio.post(
        '/community/posts/$postId/like',
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      print('좋아요 토글 응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('좋아요 상태가 성공적으로 변경되었습니다.');
      } else {
        throw Exception('좋아요 처리 실패 : ${response.statusCode}');
      }
    } catch (e) {
      print('좋아요 토글 요청 실패: $e');
      throw Exception('서버와 연결 실패 또는 좋아요 처리 중 오류: $e');
    }
  }
}
