import 'package:dio/dio.dart';
import '../../../_core/utils/my_http.dart';

class GeocodingRepository {
  Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    print("1. getAddressFromCoordinates 시작: lat=$latitude, lon=$longitude");
    try {
      print("2. 서버에 주소 변환 요청 전송");
      final response = await dio.get(
        '$baseUrl/naver/map/geocode',
        queryParameters: {
          'longitude': longitude,
          'latitude': latitude,
        },
      );
      print("3. 서버 응답 수신: ${response.statusCode}, 데이터: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final address = response.data as String?;
        print("4. 주소 파싱 성공: $address");
        return address ?? '주소를 찾을 수 없습니다.';
      }
      print("5. 주소 변환 실패 (상태 코드 200이 아님 또는 데이터가 null)");
      return '주소 변환 실패';
    } catch (e) {
      print("6. 오류 발생: $e");
      return '주소 정보를 불러오는 중 오류 발생';
    }
  }
}
