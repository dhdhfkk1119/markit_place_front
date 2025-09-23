import 'dart:convert';
import 'package:http/http.dart' as http;
import 'profile_dto.dart';

// 프로필 관련 API 통신을 담당하는 레포지토리
class ProfileRepository {
  final String baseUrl;
  ProfileRepository({required this.baseUrl});

  // 프로필 수정 PATCH API 호출
  Future<ProfileEditResponseDto> editProfile({
    required String accessToken,
    required ProfileEditRequestDto dto,
  }) async {
    // baseUrl에 이미 /api가 포함되어 있으므로 중복 제거
    final url = Uri.parse('$baseUrl/members/me');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dto.toJson()),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ProfileEditResponseDto.fromJson(json);
    } else {
      throw Exception('프로필 수정 실패: ${response.body}');
    }
  }
}
