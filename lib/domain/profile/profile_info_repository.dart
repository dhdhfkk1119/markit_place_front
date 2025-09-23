import 'dart:convert';
import 'package:http/http.dart' as http;
import '../members/repositories/member_auth_repository.dart';
import 'profile_info_dto.dart';
import '../../../../_core/utils/my_http.dart'; // secureStorage, tokenKey import

// 프로필 정보 조회 API 통신
class ProfileInfoRepository {
  final String baseUrl;
  ProfileInfoRepository({required this.baseUrl});

  Future<ProfileInfoResponseDto> fetchProfileInfo(
      {required String accessToken}) async {
    final url = Uri.parse('$baseUrl/members/me');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ProfileInfoResponseDto.fromJson(json);
    } else if (response.statusCode == 401) {
      print(
          '[ProfileInfoRepository] 401 Unauthorized - 토큰 만료. 토큰 삭제 및 로그인 화면 이동');
      await secureStorage.delete(key: tokenKey);
      throw Exception('토큰이 만료되었습니다. 다시 로그인해주세요.');
    } else {
      throw Exception('프로필 정보 조회 실패: ${response.body}');
    }
  }
}
