import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../_core/utils/my_http.dart';

final FlutterSecureStorage _storage = FlutterSecureStorage();

class NoticeListRepository {
  Future<Map<String, dynamic>> noticeList({int page = 0, int size = 10}) async {
    final token = await _storage.read(key: "accessToken");

    try {
      final response = await dio.get("/notices",
          queryParameters: {'page': page, 'size': size},
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ));
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to connect to the server');
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }
}
