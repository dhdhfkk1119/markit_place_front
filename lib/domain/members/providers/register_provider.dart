// D:/workspace-flutter/markit_place_front/lib/domain/members/providers/register_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../_core/utils/error_utils.dart';
import '../models/member.dart';

import '../repositories/registration_repository.dart';

final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  return RegistrationRepository();
});

enum RegisterStatus {
  initial,
  loading,
  success,
  idAvailable,
  idUnavailable,
  error,
}

class RegisterState {
  final RegisterStatus status;
  final String? successMessage;
  final String? errorMessage;
  final bool? isIdChecked;

  RegisterState({
    this.status = RegisterStatus.initial,
    this.successMessage,
    this.errorMessage,
    this.isIdChecked,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    String? successMessage,
    String? errorMessage,
    bool? isIdChecked,
    bool clearMessages = false,
  }) {
    return RegisterState(
      status: status ?? this.status,
      successMessage:
          clearMessages ? null : successMessage ?? this.successMessage,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      isIdChecked: isIdChecked ?? this.isIdChecked,
    );
  }
}

class RegisterNotifier extends AutoDisposeNotifier<RegisterState> {
  late RegistrationRepository _registrationRepository;

  @override
  RegisterState build() {
    _registrationRepository = ref.watch(registrationRepositoryProvider);
    return RegisterState();
  }

  Future<void> register(Member memberToRegister) async {
    state = state.copyWith(status: RegisterStatus.loading, clearMessages: true);
    try {
      await _registrationRepository.register(memberToRegister);
      state = state.copyWith(
          status: RegisterStatus.success, successMessage: "회원가입 성공! 로그인해주세요.");
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      state = state.copyWith(
          status: RegisterStatus.error, errorMessage: errorMessage);
    }
  }

  Future<bool> checkIdAvailability(String loginId) async {
    state = state.copyWith(
        status: RegisterStatus.loading,
        clearMessages: true,
        isIdChecked: false);
    try {
      final isAvailable =
          await _registrationRepository.checkIdAvailability(loginId);
      if (isAvailable) {
        state = state.copyWith(
            status: RegisterStatus.idAvailable,
            errorMessage: "사용 가능한 아이디입니다.",
            isIdChecked: true);
        return true;
      } else {
        state = state.copyWith(
            status: RegisterStatus.idUnavailable,
            errorMessage: "이미 사용 중인 아이디입니다.",
            isIdChecked: true);
        return false;
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      state = state.copyWith(
          status: RegisterStatus.error,
          errorMessage: "아이디 중복 확인 중 오류: $errorMessage",
          isIdChecked: true);
      return false;
    }
  }

  void resetRegisterState() {
    state = RegisterState();
  }

  void consumeMessages() {
    state = state.copyWith(clearMessages: true, status: RegisterStatus.initial);
  }
}

final registerNotifierProvider =
    AutoDisposeNotifierProvider<RegisterNotifier, RegisterState>(() {
  return RegisterNotifier();
});
