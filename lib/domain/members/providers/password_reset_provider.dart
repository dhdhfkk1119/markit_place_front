import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/utils/validator_util.dart'; // validator_util.dart import 추가
import 'package:markit_place_front/domain/members/repositories/find_account_repository.dart';
import '../dtos/password_reset_dtos.dart';

enum PasswordResetStep {
  enterIdentifier,
  enterCode,
  enterNewPassword,
  success,
  error
}

class PasswordResetState {
  final PasswordResetStep step;
  final String? loginId;
  final String? emailForCodeConfirmation;
  final String? tempResetToken;
  final bool isLoading;
  final String? errorMessage;

  PasswordResetState({
    this.step = PasswordResetStep.enterIdentifier,
    this.loginId,
    this.emailForCodeConfirmation,
    this.tempResetToken,
    this.isLoading = false,
    this.errorMessage,
  });

  PasswordResetState copyWith({
    PasswordResetStep? step,
    String? loginId,
    String? emailForCodeConfirmation,
    String? tempResetToken,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearToken = false,
    bool clearLoginDetails = false,
  }) {
    return PasswordResetState(
      step: step ?? this.step,
      loginId: clearLoginDetails ? null : loginId ?? this.loginId,
      emailForCodeConfirmation: clearLoginDetails
          ? null
          : emailForCodeConfirmation ?? this.emailForCodeConfirmation,
      tempResetToken: clearToken ? null : tempResetToken ?? this.tempResetToken,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PasswordResetNotifier extends Notifier<PasswordResetState> {
  late FindAccountRepository _repository;

  @override
  PasswordResetState build() {
    _repository = ref.watch(findAccountRepositoryProvider);
    return PasswordResetState();
  }

  Future<void> sendPasswordResetCode(String loginId, String email) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      loginId: loginId,
      emailForCodeConfirmation: email,
    );
    try {
      final requestDto =
          SendPasswordResetCodeRequestDto(loginId: loginId, email: email);
      await _repository.sendPasswordResetCode(requestDto);
      state = state.copyWith(
        isLoading: false,
        step: PasswordResetStep.enterCode,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst("Exception: ", ""),
        step: PasswordResetStep.error,
      );
    }
  }

  Future<void> confirmPasswordResetCode(String code) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      print('[PasswordResetNotifier] confirmPasswordResetCode CALLED.');
      print(
          '[PasswordResetNotifier] Current emailForCodeConfirmation: ${state.emailForCodeConfirmation}');
      print('[PasswordResetNotifier] Current code from UI: $code');

      if (state.emailForCodeConfirmation == null ||
          state.emailForCodeConfirmation!.trim().isEmpty) {
        print(
            '[PasswordResetNotifier] Error: emailForCodeConfirmation is null or empty.');
        throw Exception("이메일 정보가 없습니다. 처음부터 다시 시도해주세요.");
      }
      if (code.trim().isEmpty) {
        print('[PasswordResetNotifier] Error: code from UI is empty.');
        throw Exception("인증 코드를 입력해주세요.");
      }

      final requestDto = ConfirmPasswordResetCodeRequestDto(
          email: state.emailForCodeConfirmation!, code: code.trim());

      print(
          '[PasswordResetNotifier] Sending ConfirmPasswordResetCodeRequestDto: ${requestDto.toJson()}');

      final responseDto =
          await _repository.confirmPasswordResetCode(requestDto);

      state = state.copyWith(
        isLoading: false,
        tempResetToken: responseDto.tempToken,
        step: PasswordResetStep.enterNewPassword,
      );
    } catch (e) {
      print(
          '[PasswordResetNotifier] Exception in confirmPasswordResetCode: ${e.toString()}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst("Exception: ", ""),
        step: PasswordResetStep.error,
      );
    }
  }

  Future<void> resetPassword(
      String newPassword, String confirmNewPassword) async {
    // 1. 빈 값 검사
    if (newPassword.isEmpty || confirmNewPassword.isEmpty) {
      state = state.copyWith(
          errorMessage: '새 비밀번호와 확인 비밀번호를 모두 입력해주세요.',
          step: PasswordResetStep.enterNewPassword,
          clearError: false); // 이전 오류 메시지를 유지하지 않도록 clearError: false 또는 명시적 설정
      return;
    }

    // 2. 새 비밀번호 자체의 유효성 검사 (validator_util.dart 사용)
    final String passwordValidationError = validatePassword(newPassword);
    if (passwordValidationError.isNotEmpty) {
      state = state.copyWith(
          errorMessage: passwordValidationError,
          step: PasswordResetStep.enterNewPassword,
          clearError: false);
      return;
    }

    // 3. 일치 여부 검사
    if (newPassword != confirmNewPassword) {
      state = state.copyWith(
          errorMessage: '새 비밀번호가 일치하지 않습니다.',
          step: PasswordResetStep.enterNewPassword,
          clearError: false);
      return;
    }

    // 4. 임시 토큰 존재 여부 검사
    if (state.tempResetToken == null) {
      state = state.copyWith(
          errorMessage: '비밀번호 재설정을 위한 정보가 없습니다. 다시 시도해주세요.',
          step: PasswordResetStep.error, // 이 경우는 복구 불가능한 오류로 간주
          clearError: false);
      return;
    }

    // 모든 검사 통과 후 API 호출
    state = state.copyWith(
        isLoading: true, clearError: true); // API 호출 전에는 이전 오류 메시지 클리어
    try {
      final requestDto = PasswordResetRequestDto(
          tempToken: state.tempResetToken!,
          newPassword: newPassword,
          confirmNewPassword: confirmNewPassword);
      await _repository.resetPassword(requestDto);
      state = state.copyWith(
          isLoading: false,
          step: PasswordResetStep.success,
          clearToken: true,
          clearLoginDetails: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst("Exception: ", ""),
        step: PasswordResetStep.error, // API 호출 실패 시에도 복구 불가능한 오류로 간주
      );
    }
  }

  void resetToInitial() {
    state = PasswordResetState();
  }
}

final passwordResetProvider =
    NotifierProvider<PasswordResetNotifier, PasswordResetState>(() {
  return PasswordResetNotifier();
});
