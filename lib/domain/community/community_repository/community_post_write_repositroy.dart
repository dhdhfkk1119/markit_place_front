import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/domain/community/community_dto/community_post_write_dto.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

class CommunityPostWriteRepository {
  final Dio _dio = Dio();

  Future<void> createPost(CommunityPostWriteDTO postData) async {
    try {
      final accessToken = await _storage.read(key: "accessToken");
      if (accessToken == null) {
        throw Exception("인증 토근이 없습니다. 로그인 상태를 확인해주세요.");
      }

      await _dio.post(
        "$baseUrl/community/posts",
        data: postData.fromJson(),
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
        if (e.response?.statusCode == 401) {
          throw Exception("게시글 작성 실패 : 인증 토큰이 유효하지 않습니다. 다시 로그인 해주세요.");
        }
      }
      throw Exception('게시글 작성 실패 : ${e.message}');
    }
  }
}
