// D:/workspace-flutter/markit_place_front/lib/domain/members/providers/member_login_form_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:logger/logger.dart'; // 필요 시 사용
import 'package:markit_place_front/_core/utils/validator_util.dart'; // validator_util.dart 경로 확인

class MemberLoginFormModel {
  final String username;
  final String password;

  final String usernameError;
  final String passwordError;

  MemberLoginFormModel(
    this.username,
    this.password,
    this.usernameError,
    this.passwordError,
  );

  MemberLoginFormModel copyWith({
    String? username,
    String? password,
    String? usernameError,
    String? passwordError,
  }) {
    return MemberLoginFormModel(
      username ?? this.username,
      password ?? this.password,
      usernameError ?? this.usernameError,
      passwordError ?? this.passwordError,
    );
  }

  @override
  String toString() {
    return 'MemberLoginFormModel{username: $username, password: $password, usernameError: $usernameError, passwordError: $passwordError}';
  }
}

class MemberLoginFormNotifier
    extends AutoDisposeNotifier<MemberLoginFormModel> {
  @override
  MemberLoginFormModel build() {
    return MemberLoginFormModel("", "", "", "");
  }

  void updateUsername(String username) {
    final String error = validateUsername(username);
    state = state.copyWith(
      username: username,
      usernameError: error,
    );
  }

  void updatePassword(String password) {
    String passwordError = validatePassword(password);
    state = state.copyWith(
      password: password,
      passwordError: passwordError,
    );
  }

  bool validateForm() {
    final usernameError = validateUsername(state.username);
    final passwordError = validatePassword(state.password);
    // 폼 제출 시 유효성 검사 결과를 즉시 state에 반영
    state = state.copyWith(
        usernameError: usernameError, passwordError: passwordError);
    return usernameError.isEmpty && passwordError.isEmpty;
  }
}

final memberLoginFormProvider =
    AutoDisposeNotifierProvider<MemberLoginFormNotifier, MemberLoginFormModel>(
        () => MemberLoginFormNotifier());
