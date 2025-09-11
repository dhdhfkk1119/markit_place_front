import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/domain/models/user.dart';
import 'package:markit_place_front/domain/repositories/auth_repository/user_repository.dart';

// secure_storage 전역 인스턴스
final secureStorage = FlutterSecureStorage();

class SessionModel {
  User? user;
  bool? isLogin;

  SessionModel({this.user, this.isLogin = false});
}

class SessionNotifier extends Notifier<SessionModel> {
  final _logger = Logger();

  @override
  SessionModel build() {
    return SessionModel();
  }

  // 로그인 로직 (Dio 인터셉터와 함께 동작)
  Future<Map<String, dynamic>> login(String loginId, String password,
      {required bool autoLogin}) async {
    try {
      Response response = await UserRepository().login(loginId, password);

      Map<String, dynamic> body = response.data;

      // 로그인 성공 여부 먼저 확인
      if (body["success"] == false) {
        return body;
      }

      // 서버 응답에서 사용자 정보 추출
      final userMap = body['response'];
      final User user = User.fromMap(userMap);

      state = SessionModel(user: user, isLogin: true);
      _logger.d("로그인 성공");

      if (autoLogin) {
        final accessToken = response.headers.value("Authorization");
        if (accessToken != null) {
          await secureStorage.write(key: "accessToken", value: accessToken);
          _logger.d("토큰이 SecureStorage에 저장되었습니다.", accessToken);
        }
      } else {
        // 체크 하지 않으면 해당 토큰 삭제
        await secureStorage.delete(key: "accessToken");
      }

      return {"success": true};
    } on DioException catch (e) {
      _logger.e("로그인 중 네트워크 오류 발생: ${e.message}");
      return {"success": false, "errorMessage": "서버 연결에 실패했습니다."};
    } catch (e) {
      _logger.e("로그인 중 알 수 없는 오류 발생: $e");
      return {"success": false, "errorMessage": "알 수 없는 오류가 발생했습니다."};
    }
  }

  // 로그아웃 로직 (선택적)
  Future<void> logout() async {
    await secureStorage.delete(key: "accessToken");
    state = SessionModel(user: null, isLogin: false);
    _logger.d("로그아웃 성공");
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionModel>(() {
  return SessionNotifier();
});
