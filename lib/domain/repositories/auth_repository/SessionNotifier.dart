import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/domain/models/user.dart';
import 'package:markit_place_front/domain/repositories/auth_repository/user_repository.dart';

class SessionModel {
  User? user;
  bool? isLogin;

  SessionModel({this.user, this.isLogin = false});
}

class SessionNotifier extends Notifier<SessionModel> {
  @override
  SessionModel build() {
    return SessionModel();
  }

  Future<Map<String, dynamic>> login(String loginId, String password) async {
    try {
      Map<String, dynamic> body =
          await UserRepository().login(loginId, password);

      if (body["success"] == false) {
        return body;
      }

      User user = User.fromMap(body['response']);

      // await secureStorage.write(key: "accessToken", value: user.)
      state = SessionModel(user: user, isLogin: true);

      // 로그인 성공 이후 JWT 토큰 서버측에 발급 해주기
      // dio.options.headers["Authorization"] = user.accessToken;
      return {"success": true};
    } catch (e) {
      return {"success": false, "errorMessage": "네트워크 오류발생"};
    }
  }
}
