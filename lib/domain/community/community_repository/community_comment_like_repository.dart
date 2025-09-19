import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../community_dto/community_comment_like_dot.dart';

// baseUrl 정의 (팀장 주소로 임시 설계)
const baseUrl = "http://192.168.0.128:8080/api";
final dio = Dio();
const storage = FlutterSecureStorage();

class CommunityCommentLikeRepository {
  // 좋아요 상태를 토글하는 메서드
  Future<CommunityCommentLikeDTO> toggleLike(int commentId) async {
    final token = await storage.read(key: "accessToken");
    try {
      final response = await dio.post(
        "$baseUrl/community/comment-likes/$commentId",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        return CommunityCommentLikeDTO.fromJson(response.data['data']);
      } else {
        throw Exception("Failed to toggle like. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to toggle like: $e");
    }
  }

  // 초기 좋아요 상태 및 좋아요 수를 가져오는 메서드
  Future<CommunityCommentLikeDTO> getLikeStatus(int commentId) async {
    final token = await storage.read(key: "accessToken");
    try {
      final response = await dio.get(
        "$baseUrl/community/comment-likes/$commentId",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        return CommunityCommentLikeDTO.fromJson(response.data['data']);
      } else {
        throw Exception("Failed to get like status. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to get like status: $e");
    }
  }
}