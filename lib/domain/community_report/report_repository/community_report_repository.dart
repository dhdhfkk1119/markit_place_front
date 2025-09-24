import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../_core/utils/my_http.dart';

class CommunityReportRepository {
  Future<void> reportSaveCommunity(int postId, String reason) async {
    final token = await FlutterSecureStorage().read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다');
    }

    try {
      final response = await dio.post(
        '/community/reports/posts/${postId}',
        data: {
          'reason': reason,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 || 201 == response.statusCode) {
        print("신고하기 완료 : ${response.data}");
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<Map<String, dynamic>> reportMyPost() async {
    final token = await FlutterSecureStorage().read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다');
    }
    try {
      final response = await dio.get(
        '/community/reports',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: {
          'page': 0,
          'size': 10,
        },
      );
      if (response.statusCode == 200) {
        print("Raw 응답 데이터: ${response.data}");
        print("응답 타입: ${response.data.runtimeType}");
        if (response.data['response'] != null) {
          print("리스트 데이터: ${response.data['response']}");
          print("리스트 길이: ${response.data['response'].length}");
        }
        return response.data;
      } else {
        throw Exception('Failed to load community: ${response.statusCode}');
      }
    } catch (e) {
      print("API 호출 에러: $e");
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<Map<String, dynamic>> reportDetail({required int reportId}) async {
    final token = await FlutterSecureStorage().read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다');
    }
    try {
      final response = await dio.get(
        '/community/reports/${reportId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        print("신고 게시물 상세 정보 : ${response.data}");
        return response.data;
      } else {
        throw Exception('Failed to load community: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
