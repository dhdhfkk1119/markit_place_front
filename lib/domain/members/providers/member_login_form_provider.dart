import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../_core/utils/validator_util.dart';

class MemberLoginFormModel {
  final String loginInput;
  final String password;

  final String loginInputError;
  final String passwordError;

  MemberLoginFormModel(
    this.loginInput,
    this.password,
    this.loginInputError,
    this.passwordError,
  );

  MemberLoginFormModel copyWith({
    String? loginInput,
    String? password,
    String? loginInputError,
    String? passwordError,
  }) {
    return MemberLoginFormModel(
      loginInput ?? this.loginInput,
      password ?? this.password,
      loginInputError ?? this.loginInputError,
      passwordError ?? this.passwordError,
    );
  }

  @override
  String toString() {
    return 'MemberLoginFormModel{loginInput: $loginInput, password: $password, loginInputError: $loginInputError, passwordError: $passwordError}';
  }
}

class MemberLoginFormNotifier
    extends AutoDisposeNotifier<MemberLoginFormModel> {
  @override
  MemberLoginFormModel build() {
    // 초기 모델 생성 시 필드명에 맞춰 빈 문자열로 초기화
    return MemberLoginFormModel("", "", "", "");
  }

  // 아이디 또는 이메일 입력 업데이트 메소드
  void updateLoginInput(String value) {
    // 메소드 이름도 loginInput으로 변경
    // 아이디 또는 이메일은 비어있는지만 클라이언트에서 확인
    final String error = value.trim().isEmpty ? "아이디 또는 이메일을 입력해주세요." : "";
    state = state.copyWith(
      loginInput: value,
      loginInputError: error,
    );
  }

  // 비밀번호 업데이트 메소드
  void updatePassword(String password) {
    // validator_util.dart의 validatePassword 함수를 사용하여 유효성 검사
    final String error = validatePassword(password);
    state = state.copyWith(
      password: password,
      passwordError: error,
    );
  }

  // 폼 전체 유효성 검사 메소드
  bool validateForm() {
    // 아이디 또는 이메일 필드의 유효성 검사 (비어있는지 확인)
    final String loginInputErrorMsg =
        state.loginInput.trim().isEmpty ? "아이디 또는 이메일을 입력해주세요." : "";

    // 비밀번호 필드의 유효성 검사 (validator_util.dart의 validatePassword 사용)
    final String passwordErrorMsg = validatePassword(state.password);

    // 상태 업데이트
    state = state.copyWith(
        loginInputError: loginInputErrorMsg, passwordError: passwordErrorMsg);
    // 모든 에러 메시지가 비어있으면 유효한 폼으로 간주
    return loginInputErrorMsg.isEmpty && passwordErrorMsg.isEmpty;
  }
}

// Provider 정의
final memberLoginFormProvider =
    AutoDisposeNotifierProvider<MemberLoginFormNotifier, MemberLoginFormModel>(
        () => MemberLoginFormNotifier());
