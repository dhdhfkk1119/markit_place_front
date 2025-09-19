import 'package:dio/dio.dart';
import '../../../_core/utils/my_http.dart';
import '../community_dto/community_report_dto.dart';

class CommunityCommentRepository {
  final Dio _dio;

  CommunityCommentRepository(this._dio);

  Future<ResponseDTO> getComments(int postId) async {
    try {
      final response =
          await _dio.get('${baseUrl}/community/posts/$postId/comments');
      return ResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('댓글을 불러오는 데 실패했습니다 : ${e.message}');
    }
  }
}
