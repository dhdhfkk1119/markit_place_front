import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:markit_place_front/_core/utils/validator_util.dart';

class LoginModel {
  final String username;
  final String password;

  final String usernameError;
  final String passwordError;

  LoginModel(
    this.username,
    this.password,
    this.usernameError,
    this.passwordError,
  );

  LoginModel copyWith(
      {String? username,
      String? password,
      String? usernameError,
      String? passwordError}) {
    return LoginModel(
      username ?? this.username,
      password ?? this.password,
      usernameError ?? this.usernameError,
      passwordError ?? this.passwordError,
    );
  }

  @override
  String toString() {
    return 'LoginModel{username: $username, password: $password, usernameError: $usernameError, passwordError: $passwordError}';
  }
}

class LoginFormNotifier extends AutoDisposeNotifier<LoginModel> {
  @override
  LoginModel build() {
    return LoginModel("", "", "", "");
  }

  // 유효성 즉시 검증 -> 오류 메세지를 바로 밑에 띄워주기
  void username(String username) {
    final String error = validateUsername(username);
    Logger().d(error);

    state = state.copyWith(
      username: username,
      usernameError: error,
    );
  }

  // 유효성 즉시 검증 -> 오류 메세지를 바로 밑에 띄워주기
  void password(String password) {
    String passwordError = validatePassword(password);
    if (passwordError.trim().isEmpty) {
      Logger().d(password);
    } else {
      Logger().d(passwordError);
    }
    state = state.copyWith(
      password: password,
      passwordError: passwordError,
    );
  }

  bool validate() {
    final usernameError = validateUsername(state.username);
    final passwordError = validatePassword(state.password);
    return usernameError.isEmpty && passwordError.isEmpty;
  }
}

final loginFormProvider =
    AutoDisposeNotifierProvider<LoginFormNotifier, LoginModel>(
        () => LoginFormNotifier());
