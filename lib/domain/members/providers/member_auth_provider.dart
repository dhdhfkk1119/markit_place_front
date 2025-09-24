import 'package:flutter/material.dart'; // AlertDialog를 위해 추가
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../_core/utils/error_utils.dart';
import '../../../_core/utils/validator_util.dart';
// import 'profile_provider.dart'; // 삭제
import '../../../domain/profile/profile_provider.dart'; // ProfileRepositoryProvider를 위해 추가
import '../../../main.dart';
import '../../social_login/social_login_provider.dart';
import '../models/session_user.dart';
import '../repositories/member_auth_repository.dart';

// MemberLoginFormModel 클래스 (변경 없음)
class MemberLoginFormModel {
  final String loginInput;
  final String password;
  final String loginInputError;
  final String passwordError;

  const MemberLoginFormModel({
    this.loginInput = "",
    this.password = "",
    this.loginInputError = "",
    this.passwordError = "",
  });

  MemberLoginFormModel copyWith({
    String? loginInput,
    String? password,
    String? loginInputError,
    String? passwordError,
  }) {
    return MemberLoginFormModel(
      loginInput: loginInput ?? this.loginInput,
      password: password ?? this.password,
      loginInputError: loginInputError ?? this.loginInputError,
      passwordError: passwordError ?? this.passwordError,
    );
  }
}

// AuthStatus enum (변경 없음)
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

// LoginType enum (변경 없음)
enum LoginType {
  none,
  auto,
  account,
  social,
}

// AuthState 클래스 (변경 없음)
class AuthState {
  final AuthStatus status;
  final SessionUser? user;
  final String? errorMessage;
  final LoginType loginType;
  final MemberLoginFormModel loginFormModel;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.loginType = LoginType.none,
    this.loginFormModel = const MemberLoginFormModel(),
  });

  AuthState copyWith({
    AuthStatus? status,
    SessionUser? user,
    String? errorMessage,
    LoginType? loginType,
    MemberLoginFormModel? loginFormModel,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      loginType: loginType ?? this.loginType,
      loginFormModel: loginFormModel ?? this.loginFormModel,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late MemberAuthRepository _memberAuthRepository;

  SocialLoginNotifier get _socialLoginNotifierReader =>
      ref.read(socialLoginNotifierProvider.notifier);

  @override
  AuthState build() {
    _memberAuthRepository = ref.watch(memberAuthRepositoryProvider);
    Future.microtask(() => _tryAutoLogin());
    return AuthState(loginFormModel: const MemberLoginFormModel());
  }

  void updateLoginInput(String value) {
    final String error = value.trim().isEmpty ? "아이디 또는 이메일을 입력해주세요." : "";
    state = state.copyWith(
      loginFormModel: state.loginFormModel.copyWith(
        loginInput: value,
        loginInputError: error,
      ),
    );
  }

  void updatePassword(String password) {
    final String error = validatePassword(password);
    state = state.copyWith(
      loginFormModel: state.loginFormModel.copyWith(
        password: password,
        passwordError: error,
      ),
    );
  }

  bool validateLoginForm() {
    final String loginInputErrorMsg =
        state.loginFormModel.loginInput.trim().isEmpty
            ? "아이디 또는 이메일을 입력해주세요."
            : "";
    final String passwordErrorMsg =
        validatePassword(state.loginFormModel.password);

    state = state.copyWith(
      loginFormModel: state.loginFormModel.copyWith(
        loginInputError: loginInputErrorMsg,
        passwordError: passwordErrorMsg,
      ),
    );
    return loginInputErrorMsg.isEmpty && passwordErrorMsg.isEmpty;
  }

  void resetLoginForm() {
    state = state.copyWith(loginFormModel: const MemberLoginFormModel());
  }

  void setLoading() {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
  }

  Future<void> updateUserAndAuthStatus(
    SessionUser? user,
    AuthStatus status,
    LoginType loginType, {
    String? newToken,
    String? errorMessage,
  }) async {
    print(
        "[AuthNotifier updateUserAndAuthStatus] User: ${user?.name}, Status: $status, LoginType: $loginType, NewToken: ${newToken != null}, Error: $errorMessage");

    if (user == null && status == AuthStatus.authenticated) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          loginType: LoginType.none,
          clearUser: true,
          errorMessage: errorMessage ?? "세션 또는 사용자 정보가 유효하지 않습니다.");
      await _memberAuthRepository.clearSessionData();
      return;
    }

    state = state.copyWith(
        user: user,
        status: status,
        loginType: loginType,
        clearError: errorMessage == null,
        errorMessage: errorMessage,
        loginFormModel: (status == AuthStatus.authenticated ||
                status == AuthStatus.unauthenticated)
            ? const MemberLoginFormModel()
            : state.loginFormModel);

    if (state.status == AuthStatus.authenticated && state.user != null) {
      try {
        String? tokenToStore;
        if (newToken != null && newToken.isNotEmpty) {
          tokenToStore = newToken;
        } else {
          tokenToStore = await _memberAuthRepository.getAccessToken();
        }

        if (tokenToStore != null && tokenToStore.isNotEmpty) {
          await _memberAuthRepository.storeSessionData(
              state.user!, tokenToStore);
          print(
              "[AuthNotifier] Session updated and stored for user ID: ${state.user!.memberId}. Token presence: ${tokenToStore.isNotEmpty}");
        } else {
          print(
              "[AuthNotifier updateUserAndAuthStatus] Critical: Token to store is null or empty. User: ${state.user!.memberId}. Forcing logout.");
          if (loginType == LoginType.account || loginType == LoginType.social) {
            await _performFullLogoutTasks(
                isErrorLogout: true, logoutMessage: "토큰 부재로 강제 로그아웃");
          }
        }
      } catch (e) {
        print(
            "[AuthNotifier updateUserAndAuthStatus] Error storing session: $e. Forcing logout.");
        setError("세션 저장 중 오류 발생: ${extractErrorMessage(e)}");
        await _performFullLogoutTasks(
            isErrorLogout: true, logoutMessage: "세션 저장 오류로 강제 로그아웃");
      }
    }
  }

  void setError(String errorMessage, {AuthStatus? status}) {
    state = state.copyWith(
      status: status ?? AuthStatus.error,
      errorMessage: errorMessage,
      loginType: LoginType.none,
    );
  }

  void setErrorOnAuthenticated(String errorMessage) {
    state = state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: errorMessage,
        clearError: false);
  }

  Future<void> _tryAutoLogin() async {
    setLoading();
    print("[AuthNotifier _tryAutoLogin] Attempting...");
    final String? token = await _memberAuthRepository.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final SessionUser? storedUser =
          await _memberAuthRepository.getStoredUser();
      if (storedUser != null) {
        try {
          await updateUserAndAuthStatus(
              storedUser, AuthStatus.authenticated, LoginType.auto);
          if (state.status == AuthStatus.authenticated) {
            print(
                "[AuthNotifier] Auto login successful. User: ${state.user?.name}. Fetching profile...");
            final profileRepository = ref.read(ProfileRepositoryProvider);
            final SessionUser? fullUserProfile =
                await profileRepository.getMyProfile();
            if (fullUserProfile != null) {
              await refreshSessionUser(fullUserProfile);
              print(
                  "[AuthNotifier _tryAutoLogin] Profile fetched and session refreshed.");
            } else {
              print(
                  "[AuthNotifier _tryAutoLogin] Failed to fetch profile after auto login.");
            }
          }
        } catch (e) {
          print(
              "[AuthNotifier _tryAutoLogin] Error during auto login process (update/store session or profile fetch): $e");
          await _performFullLogoutTasks(
              isErrorLogout: true,
              logoutMessage: "자동 로그인 중 오류 발생: ${extractErrorMessage(e)}");
        }
      } else {
        print(
            "[AuthNotifier _tryAutoLogin] Token found but stored user is null. Performing full logout.");
        await _performFullLogoutTasks(
            isErrorLogout: true, logoutMessage: "저장된 사용자 정보 오류");
      }
    } else {
      print(
          "[AuthNotifier _tryAutoLogin] No token found, setting to unauthenticated.");
      await updateUserAndAuthStatus(
          null, AuthStatus.unauthenticated, LoginType.none);
    }
  }

  Future<void> login() async {
    if (!validateLoginForm()) {
      return;
    }
    setLoading();
    print(
        "[AuthNotifier login] Attempting with input: ${state.loginFormModel.loginInput}");
    try {
      final loginResult = await _memberAuthRepository.login(
          state.loginFormModel.loginInput, state.loginFormModel.password);
      final SessionUser? serverUser =
          loginResult['sessionUser'] as SessionUser?;
      final String? token = loginResult['token'] as String?;

      if (serverUser != null && token != null && token.isNotEmpty) {
        await updateUserAndAuthStatus(
            serverUser, AuthStatus.authenticated, LoginType.account,
            newToken: token);
        if (state.status == AuthStatus.authenticated) {
          print(
              "[AuthNotifier] Account login successful. User: ${state.user?.name}. Fetching profile...");
          final profileRepository = ref.read(ProfileRepositoryProvider);
          final SessionUser? fullUserProfile =
              await profileRepository.getMyProfile();
          if (fullUserProfile != null) {
            await refreshSessionUser(fullUserProfile);
            print(
                "[AuthNotifier login] Profile fetched and session refreshed.");
          } else {
            print("[AuthNotifier login] Failed to fetch profile after login.");
          }
        }
        resetLoginForm();
      } else {
        print(
            "[AuthNotifier login] Login failed: serverUser or token is null/empty after successful API call.");
        throw Exception("로그인 처리 중 서버 응답 데이터가 누락되었습니다.");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print("[AuthNotifier login] Login error: $errorMessage");
      setError(errorMessage);
    }
  }

  Future<void> _performFullLogoutTasks(
      {bool isErrorLogout = false, String? logoutMessage}) async {
    if (!isErrorLogout) setLoading();
    print(
        "[AuthNotifier _performFullLogoutTasks] Initiated. ErrorLogout: $isErrorLogout. Message: $logoutMessage");

    try {
      if (await FlutterNaverLogin.isLoggedIn) {
        await FlutterNaverLogin.logOut();
        print("[AuthNotifier] Naver SDK logout successful.");
      }
      await _socialLoginNotifierReader.signOutFromGoogleSdk();
      print(
          "[AuthNotifier] Google SDK sign out attempt via SocialLoginNotifier.");
    } catch (e) {
      print(
          "[AuthNotifier _performFullLogoutTasks] Error during social SDK logout: $e");
    }

    await _memberAuthRepository.clearSessionData();
    print(
        "[AuthNotifier _performFullLogoutTasks] Session cleared from repository (SecureStorage).");

    String finalErrorMessage =
        (isErrorLogout ? state.errorMessage ?? logoutMessage : logoutMessage) ??
            "로그아웃되었습니다.";
    await updateUserAndAuthStatus(
        null, AuthStatus.unauthenticated, LoginType.none,
        errorMessage: finalErrorMessage);
    print(
        "[AuthNotifier _performFullLogoutTasks] State updated to unauthenticated. Logout completed.");
    resetLoginForm();
  }

  Future<void> logout() async {
    print("[AuthNotifier logout] Logout requested by user.");
    await _performFullLogoutTasks(logoutMessage: "성공적으로 로그아웃되었습니다.");
  }

  Future<void> handleSessionInvalidation(String serverMessage) async {
    print(
        "[AuthNotifier handleSessionInvalidation] Handling session invalidation with server message: $serverMessage");

    final currentContext = navigatorKey.currentContext;

    if (currentContext != null && currentContext.mounted) {
      await showDialog(
        context: currentContext,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("세션 만료 알림",
                style: TextStyle(fontFamily: "CookieRun")),
            content: Text(serverMessage,
                style: const TextStyle(fontFamily: "CookieRun")),
            actions: <Widget>[
              TextButton(
                child:
                    const Text("확인", style: TextStyle(fontFamily: "CookieRun")),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      print(
          "[AuthNotifier handleSessionInvalidation] No valid context to show dialog. Proceeding with direct logout.");
    }

    await _performFullLogoutTasks(
        isErrorLogout: true, logoutMessage: serverMessage);

    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/social-login', (route) => false);
    print(
        "[AuthNotifier handleSessionInvalidation] Navigated to /social-login screen.");
  }

  Future<void> refreshSessionUser(SessionUser updatedUser) async {
    if (state.status == AuthStatus.authenticated && state.user != null) {
      await updateUserAndAuthStatus(
          updatedUser, AuthStatus.authenticated, state.loginType);
      print(
          "[AuthNotifier refreshSessionUser] SessionUser refreshed with new data for ${updatedUser.name}.");
    } else {
      print(
          "[AuthNotifier refreshSessionUser] Cannot refresh SessionUser: Not authenticated or no existing user.");
    }
  }
}

final memberAuthRepositoryProvider = Provider<MemberAuthRepository>((ref) {
  return MemberAuthRepository();
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
