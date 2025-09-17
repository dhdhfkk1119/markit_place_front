import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/utils/error_utils.dart'; // For extractErrorMessage
import 'package:markit_place_front/domain/members/repositories/find_account_repository.dart';

// State Definition
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

// Notifier Definition
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

  // Optional: Method to clear messages or reset state if needed from the UI
  void clearMessages() {
    state = state.copyWith(clearInfoMessage: true, clearErrorMessage: true);
  }

  void resetState() {
    state = FindIdState();
  }
}

// Provider Definition
final findIdNotifierProvider =
    NotifierProvider<FindIdNotifier, FindIdState>(() {
  return FindIdNotifier();
});
