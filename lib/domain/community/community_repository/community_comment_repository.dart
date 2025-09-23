import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../_core/utils/my_http.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

class CommunityCommentRepository {
  final Dio _dio = dio;

  Future<void> createComment({
    required int postId,
    required String content,
  }) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다.');
    }
    try {
      final response = await _dio.post(
        '/community/comments/posts/$postId',
        data: {'content': content},
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['response'];
      } else {
        throw Exception('댓글 작성 실패 (Repository): ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('댓글 작성 중 오류 발생 (Repository): $e');
    }
  }

  Future<void> updateComment({
    required int commentId,
    required String content,
  }) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다.');
    }
    try {
      final response = await _dio.put(
        '/community/comments/${commentId}',
        data: {'content': content},
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("댓글 수정 완료: $commentId");
        return response.data;
      } else {
        throw Exception('댓글 수정 실패 (Repository): ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('댓글 수정 중 오류 발생 (Repository): $e');
    }
  }

  Future<void> deleteComment({
    required int commentId,
  }) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다.');
    }
    try {
      final response = await _dio.delete(
        '/community/comments/${commentId}',
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("댓글 삭제 완료: $commentId");
        return response.data['response'];
      } else {
        throw Exception('댓글 삭제 실패 (Repository): ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('댓글 삭제 중 오류 발생 (Repository): $e');
    }
  }
}
