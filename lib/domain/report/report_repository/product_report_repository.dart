import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../_core/utils/my_http.dart';

class ProductReportRepository {
  Future<void> reportSaveProduct(int itemId, String reason) async {
    final token = await FlutterSecureStorage().read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다');
    }

    try {
      final response = await dio.post(
        '/item-reports/${itemId}',
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

  Future<Map<String, dynamic>> reportMyProduct() async {
    final token = await FlutterSecureStorage().read(key: "accessToken");
    if (token == null) {
      throw Exception('토큰 정보가 존재하지 않습니다');
    }
    try {
      final response = await dio.get(
        '/item-reports/my',
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
        print("신고 게시물 정보 : ${response.data}");
        return response.data;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
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
        '/item-reports/${reportId}',
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
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
