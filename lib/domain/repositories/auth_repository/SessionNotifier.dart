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
    _autoLogin(); // 앱 시작 시 자동 로그인 시도
    return SessionModel();
  }

  // 자동 로그인 로직 (Dio 인터셉터와 함께 동작)
  Future<void> _autoLogin() async {
    try {
      // 1. 저장된 액세스 토큰 읽기
      final accessToken = await secureStorage.read(key: "accessToken");
      if (accessToken == null) {
        _logger.d("토큰이 없어 자동 로그인을 시도하지 않습니다.");
        return;
      }

      // Dio 인터셉터가 모든 요청에 이 토큰을 자동으로 헤더에 추가합니다.
      // 따라서 별도의 헤더 설정 없이 autoLogin API를 호출합니다.
      Map<String, dynamic> body =
          await UserRepository().autoLogin("Bearer $accessToken");

      if (body["success"] == true) {
        // 자동 로그인 성공 시 사용자 정보 업데이트
        final userMap = body['response'];
        final User user = User.fromMap(userMap);
        state = SessionModel(user: user, isLogin: true);
        _logger.d("자동 로그인 성공");
      } else {
        // 토큰이 유효하지 않으면 저장된 토큰 삭제
        _logger.d("토큰이 유효하지 않아 삭제합니다.");
        await secureStorage.delete(key: "accessToken");
        state = SessionModel(isLogin: false);
      }
    } on DioException catch (e) {
      _logger.e("자동 로그인 중 네트워크 오류 발생: ${e.message}");
      await secureStorage.delete(key: "accessToken");
      state = SessionModel(isLogin: false);
    } catch (e) {
      _logger.e("자동 로그인 중 알 수 없는 오류 발생: $e");
      await secureStorage.delete(key: "accessToken");
      state = SessionModel(isLogin: false);
    }
  }

  // 로그인 로직 (Dio 인터셉터와 함께 동작)
  Future<Map<String, dynamic>> login(String loginId, String password,
      {required bool autoLogin}) async {
    try {
      Map<String, dynamic> body =
          await UserRepository().login(loginId, password);

      if (body["success"] == false) {
        return body;
      }

      final userMap = body['response'];
      final User user = User.fromMap(userMap);

      // SessionModel 업데이트
      state = SessionModel(user: user, isLogin: true);
      _logger.d("로그인 성공");

      // if (autoLogin) {
      //   final accessToken = response.headers.value("authorization");
      //   if (accessToken != null) {
      //     await secureStorage.write(key: "accessToken", value: accessToken);
      //   }
      // }

      return {"success": true};
    } catch (e) {
      _logger.e("로그인 중 네트워크 오류 발생:");
      return {"success": false, "errorMessage": "서버가 돌아가고 있나용?"};
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
