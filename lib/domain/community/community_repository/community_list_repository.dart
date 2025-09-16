import 'package:dio/dio.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/domain/community/community_dto/community_list_dto.dart';
import 'package:markit_place_front/domain/community/community_model/community_list.dart';

String baseUrl = "http://192.168.0.128:8080/api";

class CommunityListRepository {
  Future<List<CommunityListDTO>> getCommunityList() async {
    try {
      print("Repository: API 요청 시작: ${baseUrl}/community/posts");

      final response =
          await dio.get('http://192.168.0.128:8080/api/community/posts');

      print("Repository: 응답 코드: ${response.statusCode}");
      print("Repository: 서버 응답 데이터: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data['response'];

        return dataList.map((data) {
          final model = CommunityList.fromMap(data);
          return CommunityListDTO.fromModel(model);
        }).toList();
      }
      throw Exception("커뮤니티 글 목록 실패(HTTP ${response.statusCode})");
    } on DioError catch (e) {
      print("Repository: DioError 발생: ${e.message}");
      print("Repository: 응답 데이터: ${e.response?.data}");
      throw Exception("커뮤니티 글 목록을 가져오는데 실패: ${e.message}");
    }
  }
}
