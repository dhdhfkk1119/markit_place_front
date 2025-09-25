import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../_core/utils/my_http.dart';
import '../community_dto/community_list_dto.dart';
import '../community_dto/community_post_write_dto.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

class CommunityPostWriteRepository {
  final Dio _dio;

  CommunityPostWriteRepository(this._dio);

  Future<void> createPost(CommunityPostWriteDTO postData) async {
    try {
      final accessToken = await _storage.read(key: "accessToken");
      if (accessToken == null) {
        throw Exception("인증 토큰이 없습니다. 로그인 상태를 확인해주세요.");
      }

      await _dio.post(
        "$baseUrl/community/posts",
        data: postData.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      print('게시글 작성 요청 성공');
    } on DioException catch (e) {
      if (e.response != null) {
        print('오류 상태 코드 : ${e.response?.statusCode}');
        String errorMessage =
            e.response?.data['message'] ?? '알 수 없는 오류가 발생했습니다.';
        if (e.response?.statusCode == 401) {
          throw Exception("게시글 작성 실패: 인증 토큰이 유효하지 않습니다. 다시 로그인 해주세요.");
        }
        throw Exception("게시글 작성 실패: $errorMessage");
      }
      throw Exception('게시글 작성 실패: ${e.message}');
    }
  }

  Future<void> updatePost(
      int postId, CommunityPostWriteDTO postData) async {
    try {
      final accessToken = await _storage.read(key: "accessToken");
      if (accessToken == null) {
        throw Exception("인증 토큰이 없습니다. 로그인 상태를 확인해주세요.");
      }

      final response = await _dio.put(
        "$baseUrl/community/posts/$postId",
        data: postData.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      print('게시글 수정 요청 성공');

      final responseBody = response.data?['response'];
      if (responseBody == null) {
        throw Exception("서버 응답 데이터가 유효하지 않습니다.");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('오류 상태 코드 : ${e.response?.statusCode}');
        String errorMessage =
            e.response?.data['message'] ?? '알 수 없는 오류가 발생했습니다.';
        if (e.response?.statusCode == 401) {
          throw Exception("게시글 수정 실패: 인증 토큰이 유효하지 않습니다. 다시 로그인 해주세요.");
        }
        throw Exception("게시글 수정 실패: $errorMessage");
      }
      throw Exception('게시글 수정 실패: ${e.message}');
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      final accessToken = await _storage.read(key: "accessToken");
      if (accessToken == null) {
        throw Exception("인증 토큰이 없습니다. 로그인 상태를 확인해주세요.");
      }

      await _dio.delete(
        "$baseUrl/community/posts/$postId",
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      print('게시글 삭제 요청 성공');
    } on DioException catch (e) {
      if (e.response != null) {
        print('오류 상태 코드 : ${e.response?.statusCode}');
        String errorMessage =
            e.response?.data['message'] ?? '알 수 없는 오류가 발생했습니다.';
        if (e.response?.statusCode == 401) {
          throw Exception("게시글 삭제 실패: 인증 토큰이 유효하지 않습니다. 다시 로그인 해주세요.");
        }
        throw Exception("게시글 삭제 실패: $errorMessage");
      }
      throw Exception('게시글 삭제 실패: ${e.message}');
    }
  }
}
