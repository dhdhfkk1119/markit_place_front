import 'package:dio/dio.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/domain/community/community_dto/community_report_dto.dart';

class CommunityReportRepository {
  final Dio _dio;

  CommunityReportRepository(this._dio);

  Future<ResponseDTO> getReports() async {
    try {
      Response response = await _dio.get("${baseUrl}/api/reports");
      return ResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('신고 목록을 가져오는 중 오류가 발생했습니다 : ${e.message}');
    }
  }

  Future<ResponseDTO> reportPost(CommunityReportDTO communityReportDTO) async {
    try {
      Response response = await _dio.post(
        "${baseUrl}/api/reports",
        data: communityReportDTO.toJson(),
      );
      return ResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('게시글 신고 중 오류가 발생 했습니다 : ${e.message}');
    }
  }

  Future<ResponseDTO> updateReportStatus(int reportId, String newStatus) async {
    try {
      final response = await _dio.put(
        '${baseUrl}/api/reports/$reportId',
        data: {'status': newStatus},
      );
      return ResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('신고 상태 업데이트 중 오류가 발생했습니다 : ${e.message}');
    }
  }

  Future<ResponseDTO> deleteReport(int reportId) async {
    try {
      final response = await _dio.delete('${baseUrl}/api/reports/$reportId');
      return ResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('신고 삭제 중 오류가 발생했습니다 : ${e.message}');
    }
  }
}
