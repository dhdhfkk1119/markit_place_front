import 'package:flutter/material.dart';
import '../../_core/utils/my_http.dart';

class NaverMapRepository {
  Future<String> fetchClientId() async {
    try {
      final response = await dio.get("/naver/map/client-id");
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      debugPrint("Failed to fetch client ID: $e");
    }
    return "fail";
  }
}
