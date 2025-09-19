// D:/workspace-flutter/markit_place_front/lib/domain/members/providers/find_account_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../_core/utils/error_utils.dart'; // For extractErrorMessage
import '../../../_core/utils/validator_util.dart';
import '../repositories/find_account_repository.dart';
import '../dtos/password_reset_dtos.dart'; // From password_reset_provider

// --- Repositories Provider ---
final findAccountRepositoryProvider = Provider<FindAccountRepository>((ref) {
  return FindAccountRepository();
});

// --- Find ID Related ---
// State Definition for Find ID
class FindIdState {
  final bool isLoadingMaskedId;
  final bool isLoadingSendEmail;
  final String? maskedId;
  final String? infoMessage; // For success messages like "ID sent to email"
  final String? errorMessage;

  FindIdState({
    this.isLoadingMaskedId = false,
    this.isLoadingSendEmail = false,
    this.maskedId,
    this.infoMessage,
    this.errorMessage,
  });

  FindIdState copyWith({
    bool? isLoadingMaskedId,
    bool? isLoadingSendEmail,
    String? maskedId,
    String? infoMessage,
    String? errorMessage,
    bool clearMaskedId = false,
    bool clearInfoMessage = false,
    bool clearErrorMessage = false,
  }) {
    return FindIdState(
      isLoadingMaskedId: isLoadingMaskedId ?? this.isLoadingMaskedId,
      isLoadingSendEmail: isLoadingSendEmail ?? this.isLoadingSendEmail,
      maskedId: clearMaskedId ? null : maskedId ?? this.maskedId,
      infoMessage: clearInfoMessage ? null : infoMessage ?? this.infoMessage,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier Definition for Find ID
class FindIdNotifier extends Notifier<FindIdState> {
  late FindAccountRepository _findAccountRepository;

  @override
  FindIdState build() {
    _findAccountRepository = ref.watch(findAccountRepositoryProvider);
    return FindIdState();
  }

  Future<void> fetchMaskedId(String email) async {
    state = state.copyWith(
      isLoadingMaskedId: true,
      clearMaskedId: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );
    try {
      final fetchedMaskedId = await _findAccountRepository.getMaskedId(email);
      state = state.copyWith(
        isLoadingMaskedId: false,
        maskedId: fetchedMaskedId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMaskedId: false,
        errorMessage: extractErrorMessage(e),
      );
    }
  }

  Future<void> sendLoginIdToEmail(String email) async {
    state = state.copyWith(
      isLoadingSendEmail: true,
      clearInfoMessage: true,
      clearErrorMessage: true,
      // Optional: clear maskedId if this action implies starting over
      // clearMaskedId: true,
    );
    try {
      final successMessage =
          await _findAccountRepository.sendFullIdToEmail(email);
      state = state.copyWith(
        isLoadingSendEmail: false,
        infoMessage: successMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSendEmail: false,
        errorMessage: extractErrorMessage(e),
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(clearInfoMessage: true, clearErrorMessage: true);
  }

  void resetState() {
    state = FindIdState();
  }
}

// Provider Definition for Find ID
final findIdNotifierProvider =
    NotifierProvider<FindIdNotifier, FindIdState>(() {
  return FindIdNotifier();
});

// --- Password Reset Related ---
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
      if (state.emailForCodeConfirmation == null ||
          state.emailForCodeConfirmation!.trim().isEmpty) {
        throw Exception("이메일 정보가 없습니다. 처음부터 다시 시도해주세요.");
      }
      if (code.trim().isEmpty) {
        throw Exception("인증 코드를 입력해주세요.");
      }

      final requestDto = ConfirmPasswordResetCodeRequestDto(
          email: state.emailForCodeConfirmation!, code: code.trim());
      final responseDto =
          await _repository.confirmPasswordResetCode(requestDto);

      state = state.copyWith(
        isLoading: false,
        tempResetToken: responseDto.tempToken,
        step: PasswordResetStep.enterNewPassword,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst("Exception: ", ""),
        step: PasswordResetStep.error,
      );
    }
  }

  Future<void> resetPassword(
      String newPassword, String confirmNewPassword) async {
    if (newPassword.isEmpty || confirmNewPassword.isEmpty) {
      state = state.copyWith(
          errorMessage: '새 비밀번호와 확인 비밀번호를 모두 입력해주세요.',
          step: PasswordResetStep.enterNewPassword,
          clearError: false);
      return;
    }

    final String passwordValidationError = validatePassword(newPassword);
    if (passwordValidationError.isNotEmpty) {
      state = state.copyWith(
          errorMessage: passwordValidationError,
          step: PasswordResetStep.enterNewPassword,
          clearError: false);
      return;
    }

    if (newPassword != confirmNewPassword) {
      state = state.copyWith(
          errorMessage: '새 비밀번호가 일치하지 않습니다.',
          step: PasswordResetStep.enterNewPassword,
          clearError: false);
      return;
    }

    if (state.tempResetToken == null) {
      state = state.copyWith(
          errorMessage: '비밀번호 재설정을 위한 정보가 없습니다. 다시 시도해주세요.',
          step: PasswordResetStep.error,
          clearError: false);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
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
        step: PasswordResetStep.error,
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
