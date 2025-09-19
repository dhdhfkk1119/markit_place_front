// D:/workspace-flutter/markit_place_front/lib/domain/members/providers/email_verification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../_core/utils/error_utils.dart';
import '../repositories/email_verification_repository.dart'; // Repository import
// import '../repositories/member_auth_repository.dart'; // 이 파일에서 직접 사용하지 않으므로 주석 처리 또는 삭제

// Provider 정의를 이곳으로 이동
final emailVerificationRepositoryProvider =
    Provider<EmailVerificationRepository>((ref) {
  return EmailVerificationRepository();
});

enum EmailVerificationStatus {
  initial,
  codeSent,
  verified,
  loading,
  error,
}

class EmailVerificationState {
  final EmailVerificationStatus status;
  final String? email;
  final String? errorMessage;
  final bool isVerifiedForCurrentSession;

  EmailVerificationState({
    this.status = EmailVerificationStatus.initial,
    this.email,
    this.errorMessage,
    this.isVerifiedForCurrentSession = false,
  });

  EmailVerificationState copyWith({
    EmailVerificationStatus? status,
    String? email,
    String? errorMessage,
    bool? isVerifiedForCurrentSession,
    bool clearError = false,
    bool clearEmail = false,
  }) {
    return EmailVerificationState(
      status: status ?? this.status,
      email: clearEmail ? null : email ?? this.email,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isVerifiedForCurrentSession:
          isVerifiedForCurrentSession ?? this.isVerifiedForCurrentSession,
    );
  }
}

class EmailVerificationNotifier extends Notifier<EmailVerificationState> {
  late EmailVerificationRepository _repository;

  @override
  EmailVerificationState build() {
    _repository = ref.watch(
        emailVerificationRepositoryProvider); // 이제 이 파일 내에 Provider가 정의되어 있음
    return EmailVerificationState();
  }

  Future<void> requestEmailVerification(String email) async {
    state = state.copyWith(
        status: EmailVerificationStatus.loading,
        email: email,
        clearError: true,
        isVerifiedForCurrentSession: false);
    try {
      await _repository.requestEmailVerification(email);
      state = state.copyWith(status: EmailVerificationStatus.codeSent);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      state = state.copyWith(
          status: EmailVerificationStatus.error, errorMessage: errorMessage);
    }
  }

  Future<bool> confirmEmailVerification(String email, String code) async {
    state = state.copyWith(
        status: EmailVerificationStatus.loading,
        email: email,
        clearError: true);
    try {
      final isVerified =
          await _repository.confirmEmailVerification(email, code);
      if (isVerified) {
        state = state.copyWith(
            status: EmailVerificationStatus.verified,
            isVerifiedForCurrentSession: true);
        return true;
      } else {
        state = state.copyWith(
            status: EmailVerificationStatus.error,
            errorMessage: "인증번호가 일치하지 않습니다.",
            isVerifiedForCurrentSession: false);
        return false;
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      state = state.copyWith(
          status: EmailVerificationStatus.error,
          errorMessage: errorMessage,
          isVerifiedForCurrentSession: false);
      return false;
    }
  }

  void resetEmailVerificationState() {
    state = EmailVerificationState();
  }

  void consumeVerificationSuccess() {
    if (state.status == EmailVerificationStatus.verified) {
      state = state.copyWith(
          isVerifiedForCurrentSession: false,
          status: EmailVerificationStatus.initial,
          clearEmail: true);
    }
  }
}

final emailVerificationNotifierProvider =
    NotifierProvider<EmailVerificationNotifier, EmailVerificationState>(() {
  return EmailVerificationNotifier();
});
