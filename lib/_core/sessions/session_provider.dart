// lib/_core/sessions/providers/session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import '../../../_core/utils/error_utils.dart';
import 'session_repository.dart';
import 'session_user.dart';

// 1. 세션 상태 관련 Enum 및 클래스 정의
enum SessionStatus { initial, loading, authenticated, unauthenticated, error }

enum LoginType { none, auto, account, social }

class SessionState {
  final SessionStatus status;
  final SessionUser? user;
  final String? errorMessage;
  final LoginType loginType;

  SessionState({
    this.status = SessionStatus.initial,
    this.user,
    this.errorMessage,
    this.loginType = LoginType.none,
  });

  SessionState copyWith({
    SessionStatus? status,
    SessionUser? user,
    String? errorMessage,
    LoginType? loginType,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      loginType: loginType ?? this.loginType,
    );
  }
}

// 2. SessionRepository를 위한 Provider 정의
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final secureStorage = ref.watch(
      flutterSecureStorageProvider); // SessionRepository.dart에 정의된 Provider
  return SessionRepository(secureStorage);
});

// 3. SessionNotifier 클래스 정의
class SessionNotifier extends Notifier<SessionState> {
  late SessionRepository _sessionRepository;

  @override
  SessionState build() {
    _sessionRepository = ref.watch(sessionRepositoryProvider);
    Future.microtask(() => tryAutoLogin());
    return SessionState();
  }

  void _setLoading() {
    state = state.copyWith(status: SessionStatus.loading, clearError: true);
  }

  void _setError(String errorMessage, {SessionStatus? status}) {
    state = state.copyWith(
      status: status ?? SessionStatus.error,
      errorMessage: errorMessage,
      loginType: LoginType.none,
    );
  }

  Future<void> updateSessionUserAndStatus(
    SessionUser? user,
    SessionStatus status,
    LoginType loginType, {
    String? newToken,
    String? errorMessage,
  }) async {
    print(
        "[SessionProvider updateSessionUserAndStatus] User: \${user?.name}, Status: \$status, LoginType: \$loginType, NewToken: \${newToken != null}, Error: \$errorMessage");

    if (user == null && status == SessionStatus.authenticated) {
      state = state.copyWith(
          status: SessionStatus.unauthenticated,
          loginType: LoginType.none,
          clearUser: true,
          errorMessage: errorMessage ?? "세션 또는 사용자 정보가 유효하지 않습니다.");
      await _sessionRepository.clearSessionData();
      return;
    }

    state = state.copyWith(
        user: user,
        status: status,
        loginType: loginType,
        clearError: errorMessage == null,
        errorMessage: errorMessage);

    if (state.status == SessionStatus.authenticated && state.user != null) {
      try {
        String? tokenToStore =
            newToken ?? await _sessionRepository.getAccessToken();
        if (tokenToStore != null && tokenToStore.isNotEmpty) {
          await _sessionRepository.storeSessionData(state.user!, tokenToStore);
          print(
              "[SessionProvider] Session updated and stored for user ID: \${state.user!.memberId}. Token presence: \${tokenToStore.isNotEmpty}");
        } else {
          print(
              "[SessionProvider] Warning: Token to store is null or empty. User: \${state.user!.memberId}. Forcing logout.");
          if (loginType == LoginType.account || loginType == LoginType.social) {
            await performFullLogout(
                isErrorLogout: true, logoutMessage: "토큰 부재로 강제 로그아웃");
          }
        }
      } catch (e) {
        print("[SessionProvider] Error storing session: \$e. Forcing logout.");
        _setError("세션 저장 중 오류 발생: \${extractErrorMessage(e)}");
        await performFullLogout(
            isErrorLogout: true, logoutMessage: "세션 저장 오류로 강제 로그아웃");
      }
    }
  }

  Future<void> tryAutoLogin() async {
    _setLoading();
    print("[SessionProvider tryAutoLogin] Attempting...");
    final String? token = await _sessionRepository.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final SessionUser? storedUser = await _sessionRepository.getStoredUser();
      if (storedUser != null) {
        try {
          await updateSessionUserAndStatus(
              storedUser, SessionStatus.authenticated, LoginType.auto);
          if (state.status == SessionStatus.authenticated) {
            print(
                "[SessionProvider] Auto login successful. User: \${state.user?.name}.");
          }
        } catch (e) {
          print(
              "[SessionProvider] Error during auto login process (update/store session): \$e");
          await performFullLogout(
              isErrorLogout: true, logoutMessage: "자동 로그인 중 오류 발생");
        }
      } else {
        print(
            "[SessionProvider tryAutoLogin] Stored user is null, performing full logout.");
        await performFullLogout(isErrorLogout: false);
      }
    } else {
      print(
          "[SessionProvider tryAutoLogin] No token found, setting to unauthenticated.");
      await updateSessionUserAndStatus(
          null, SessionStatus.unauthenticated, LoginType.none);
    }
  }

  Future<void> loginWithAccount(String loginInput, String password) async {
    _setLoading();
    print(
        "[SessionProvider loginWithAccount] Attempting with input: \$loginInput");
    try {
      final loginResult = await _sessionRepository.login(loginInput, password);
      final SessionUser? serverUser =
          loginResult['sessionUser'] as SessionUser?;
      final String? token = loginResult['token'] as String?;

      if (serverUser != null && token != null && token.isNotEmpty) {
        await updateSessionUserAndStatus(
            serverUser, SessionStatus.authenticated, LoginType.account,
            newToken: token);
        if (state.status == SessionStatus.authenticated) {
          print(
              "[SessionProvider] Account login successful. User: \${state.user?.name}.");
        }
      } else {
        print(
            "[SessionProvider loginWithAccount] Login failed: serverUser or token is null/empty.");
        throw Exception("로그인 처리 중 서버 응답 데이터가 누락되었습니다.");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print("[SessionProvider loginWithAccount] Login error: \$errorMessage");
      _setError(errorMessage);
    }
  }

  Future<void> performFullLogout(
      {bool isErrorLogout = false, String? logoutMessage}) async {
    if (!isErrorLogout) _setLoading();
    print(
        "[SessionProvider performFullLogout] Initiated. ErrorLogout: \$isErrorLogout. Message: \$logoutMessage");

    try {
      if (await FlutterNaverLogin.isLoggedIn) {
        await FlutterNaverLogin.logOut();
        print("[SessionProvider] Naver SDK logout successful.");
      }
    } catch (e) {
      print("[SessionProvider] Error during social SDK logout: \$e");
    }

    await _sessionRepository.clearSessionData();
    print("[SessionProvider] Session cleared from repository (SecureStorage).");

    await updateSessionUserAndStatus(
        null, SessionStatus.unauthenticated, LoginType.none,
        errorMessage: isErrorLogout ? state.errorMessage : null);
    print(
        "[SessionProvider] State updated to unauthenticated. Logout completed.");
  }

  Future<void> refreshSessionUser(SessionUser updatedUser) async {
    if (state.status == SessionStatus.authenticated && state.user != null) {
      await updateSessionUserAndStatus(
          updatedUser, SessionStatus.authenticated, state.loginType);
      print(
          "[SessionProvider] SessionUser refreshed with new data for \${updatedUser.name}.");
    } else {
      print(
          "[SessionProvider] Cannot refresh SessionUser: Not authenticated or no existing user.");
    }
  }
}

// 4. SessionNotifier를 위한 Provider 정의
final sessionNotifierProvider =
    NotifierProvider<SessionNotifier, SessionState>(() {
  return SessionNotifier();
});
