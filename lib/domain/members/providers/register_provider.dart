// D:/workspace-flutter/markit_place_front/lib/domain/members/providers/register_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../_core/utils/error_utils.dart';
import '../models/member.dart';
// import '../repositories/member_auth_repository.dart'; // 변경
import '../repositories/registration_repository.dart'; // 추가
// import 'member_auth_provider.dart'; // MemberAuthRepositoryProvider를 직접 참조하지 않으므로 삭제 가능

// RegistrationRepository Provider 정의 추가
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
  final bool? isIdChecked; // 아이디 중복 확인 완료 여부 (성공/실패 무관)

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

class RegisterNotifier extends Notifier<RegisterState> {
  late RegistrationRepository _registrationRepository; // 변경

  @override
  RegisterState build() {
    _registrationRepository = ref.watch(registrationRepositoryProvider); // 변경
    return RegisterState();
  }

  Future<void> register(Member memberToRegister) async {
    state = state.copyWith(status: RegisterStatus.loading, clearMessages: true);
    try {
      // EmailVerificationNotifier 상태 초기화는 UI 또는 RegisterNotifier 내에서 처리 필요.
      // 예를 들어, 회원가입 성공 후 AuthNotifier가 아닌 RegisterNotifier에서 처리하거나
      // UI에서 직접 emailVerificationNotifier.resetEmailVerificationState() 호출.
      // 여기서는 EmailVerificationNotifier에 대한 직접적인 참조는 제거함.
      await _registrationRepository.register(memberToRegister); // 변경
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
        isIdChecked: false); // isIdChecked를 false로 초기화
    try {
      final isAvailable =
          await _registrationRepository.checkIdAvailability(loginId); // 변경
      if (isAvailable) {
        state = state.copyWith(
            status: RegisterStatus.idAvailable,
            errorMessage: "사용 가능한 아이디입니다.", // UI에서 활용할 수 있도록 메시지 전달
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
          isIdChecked: true); // 오류 발생 시에도 확인 시도는 한 것이므로 true
      return false; // 예외 발생 시 사용 불가능으로 간주
    }
  }

  void resetRegisterState() {
    state = RegisterState();
  }

  // UI에서 성공/에러 메시지를 소비한 후 호출하여 메시지를 지울 수 있게 함
  void consumeMessages() {
    state = state.copyWith(clearMessages: true, status: RegisterStatus.initial);
  }
}

final registerNotifierProvider =
    NotifierProvider<RegisterNotifier, RegisterState>(() {
  return RegisterNotifier();
});
