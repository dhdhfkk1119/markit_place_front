import 'dart:convert'; // jsonEncode를 사용하기 위해 추가
import 'package:flutter/material.dart'; // AlertDialog를 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // SessionService가 관리하므로 제거
import '../../../_core/utils/error_utils.dart';
import '../../../_core/utils/validator_util.dart';
import '../models/session_user.dart';
import '../repositories/member_auth_repository.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'profile_provider.dart';
import '../../social_login/social_login_provider.dart';
import '../../../main.dart'; // navigatorKey를 사용하기 위해 추가
import '../services/session_service.dart'; // SessionService import 추가

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
  late SessionService _sessionService;

  @override
  AuthState build() {
    _memberAuthRepository = ref.watch(memberAuthRepositoryProvider);
    _sessionService = ref.watch(sessionServiceProvider);
    Future.microtask(() => _tryAutoLogin());
    return AuthState(loginFormModel: const MemberLoginFormModel());
  }

  ProfileNotifier get _profileNotifierReader =>
      ref.read(profileNotifierProvider.notifier);
  SocialLoginNotifier get _socialLoginNotifierReader =>
      ref.read(socialLoginNotifierProvider.notifier);

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
    print("[AuthNotifier updateUserAndAuthStatus] Method called.");
    print(
        "[AuthNotifier updateUserAndAuthStatus] Received user: ${user != null ? jsonEncode(user.toJson()) : 'null'}");
    print("[AuthNotifier updateUserAndAuthStatus] Received status: $status");
    print(
        "[AuthNotifier updateUserAndAuthStatus] Received loginType: $loginType");
    print(
        "[AuthNotifier updateUserAndAuthStatus] Received newToken: $newToken");
    print(
        "[AuthNotifier updateUserAndAuthStatus] Received errorMessage: $errorMessage");

    if (user == null && status == AuthStatus.authenticated) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          loginType: LoginType.none,
          clearUser: true,
          errorMessage: errorMessage ?? "세션 또는 사용자 정보가 유효하지 않습니다.");
      await _sessionService.clearSession();
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

    print(
        "[AuthNotifier updateUserAndAuthStatus] State updated. Current state.user: ${state.user != null ? jsonEncode(state.user!.toJson()) : 'null'}");

    if (state.status == AuthStatus.authenticated && state.user != null) {
      try {
        String? tokenToStore;
        if (newToken != null && newToken.isNotEmpty) {
          tokenToStore = newToken;
          print(
              "[AuthNotifier updateUserAndAuthStatus] Using newToken for storage: $tokenToStore");
        } else {
          tokenToStore = await _sessionService.getAccessToken();
          print(
              "[AuthNotifier updateUserAndAuthStatus] Using existing token from session service for storage: $tokenToStore");
        }

        print(
            "[AuthNotifier updateUserAndAuthStatus] Attempting to store session. User to store: ${jsonEncode(state.user!.toJson())}, Token to store: $tokenToStore");

        if (tokenToStore != null && tokenToStore.isNotEmpty) {
          await _sessionService.storeSession(state.user!, tokenToStore);
          print(
              "[AuthNotifier] Session updated and stored for user ID: ${state.user!.memberId} with ${newToken != null && newToken.isNotEmpty ? "new" : "existing"} token.");
        } else {
          print(
              "[AuthNotifier updateUserAndAuthStatus] Warning: Token to store is null or empty. User: ${state.user!.memberId}. Forcing logout if login type was account/social.");
          if (loginType == LoginType.account || loginType == LoginType.social) {
            await _performFullLogoutTasks();
          }
        }
      } catch (e) {
        print(
            "[AuthNotifier updateUserAndAuthStatus] Error storing session: $e. Forcing logout.");
        setError("세션 저장 중 오류 발생: ${extractErrorMessage(e)}");
        await _performFullLogoutTasks();
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
    print("[AuthNotifier _tryAutoLogin] Attempting auto login...");
    final String? token = await _sessionService.getAccessToken();
    print(
        "[AuthNotifier _tryAutoLogin] Retrieved token from session service: $token");
    if (token != null && token.isNotEmpty) {
      final SessionUser? storedUser = await _sessionService.getStoredUser();
      print(
          "[AuthNotifier _tryAutoLogin] Retrieved storedUser: ${storedUser != null ? jsonEncode(storedUser.toJson()) : 'null'}");
      if (storedUser != null) {
        try {
          await updateUserAndAuthStatus(storedUser, AuthStatus.authenticated,
              LoginType.auto); // newToken is not passed here deliberately
          if (state.status == AuthStatus.authenticated) {
            await _profileNotifierReader.fetchMyProfileAndUpdateAuthNotifier(
                showLoading: false);
          }
        } catch (e) {
          print(
              "[AuthNotifier _tryAutoLogin] Error during auto login (profile fetch or session store): $e");
          await _performFullLogoutTasks();
        }
      } else {
        print(
            "[AuthNotifier _tryAutoLogin] Stored user is null, performing full logout.");
        await _performFullLogoutTasks();
      }
    } else {
      print(
          "[AuthNotifier _tryAutoLogin] Token is null or empty, updating to unauthenticated.");
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
        "[AuthNotifier login] Attempting login with input: ${state.loginFormModel.loginInput}");
    try {
      final loginResult = await _memberAuthRepository.login(
          state.loginFormModel.loginInput, state.loginFormModel.password);
      final SessionUser? serverUser =
          loginResult['sessionUser'] as SessionUser?;
      final String? token = loginResult['token'] as String?;

      print(
          "[AuthNotifier login] Login API result. serverUser: ${serverUser != null ? jsonEncode(serverUser.toJson()) : 'null'}, token: $token");

      if (serverUser != null && token != null && token.isNotEmpty) {
        await updateUserAndAuthStatus(
            serverUser, AuthStatus.authenticated, LoginType.account,
            newToken: token); // Pass newToken here
        if (state.status == AuthStatus.authenticated) {
          await _profileNotifierReader.fetchMyProfileAndUpdateAuthNotifier(
              showLoading: false);
        }
        resetLoginForm();
      } else {
        print(
            "[AuthNotifier login] Login failed: serverUser or token is null/empty.");
        throw Exception("로그인 처리 중 서버 응답 데이터가 누락되었습니다.");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print("[AuthNotifier login] Login error: $errorMessage");
      setError(errorMessage);
    }
  }

  Future<void> _performFullLogoutTasks() async {
    print(
        "[AuthNotifier _performFullLogoutTasks] Performing full logout tasks...");
    try {
      if (await FlutterNaverLogin.isLoggedIn) {
        await FlutterNaverLogin.logOut();
        print(
            "[AuthNotifier _performFullLogoutTasks] Naver SDK logout successful.");
      }
    } catch (e) {
      print(
          "[AuthNotifier _performFullLogoutTasks] Error during Naver SDK logout: $e");
    }
    await _socialLoginNotifierReader.signOutFromGoogleSdk();
    print(
        "[AuthNotifier _performFullLogoutTasks] Google SDK sign out attempt via SocialLoginNotifier.");

    await _sessionService.clearSession();
    print(
        "[AuthNotifier _performFullLogoutTasks] Session cleared from session service.");

    await updateUserAndAuthStatus(
        null, AuthStatus.unauthenticated, LoginType.none);
    print(
        "[AuthNotifier _performFullLogoutTasks] State updated to unauthenticated.");
    resetLoginForm();
  }

  Future<void> logout() async {
    print("[AuthNotifier logout] Logout requested.");
    setLoading();
    await _performFullLogoutTasks();
  }

  // Modified handleSessionInvalidation
  Future<void> handleSessionInvalidation(String serverMessage) async {
    print(
        "[AuthNotifier handleSessionInvalidation] Handling session invalidation with message: $serverMessage");

    // 로그인 화면으로 이동하는 공통 로직
    Future<void> navigateToLoginScreen() async {
      // '/social-login'을 기본 로그인 페이지로 사용
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/social-login', (route) => false);
      print(
          "[AuthNotifier handleSessionInvalidation] Navigated to /social-login screen.");
    }

    // 현재 context를 가져오려고 시도 (AlertDialog 표시에 사용)
    final currentContext = navigatorKey.currentContext;

    if (currentContext != null && currentContext.mounted) {
      // context가 유효하면 AlertDialog를 먼저 보여줌
      await showDialog(
        context: currentContext,
        barrierDismissible: false, // 사용자가 임의로 닫을 수 없도록 설정
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text("알림", style: TextStyle(fontFamily: "CookieRun")),
            content:
                Text(serverMessage, style: TextStyle(fontFamily: "CookieRun")),
            actions: <Widget>[
              TextButton(
                child: Text("확인", style: TextStyle(fontFamily: "CookieRun")),
                onPressed: () async {
                  Navigator.of(dialogContext).pop(); // AlertDialog 닫기
                },
              ),
            ],
          );
        },
      ).then((_) async {
        // AlertDialog가 닫힌 후 (사용자가 "확인"을 누른 후) 로그아웃 및 화면 이동 실행
        await _performFullLogoutTasks();
        await navigateToLoginScreen();
      });
    } else {
      // context가 유효하지 않으면 (예: 백그라운드 상태 등) AlertDialog 없이 바로 로그아웃 및 화면 이동 실행
      print(
          "[AuthNotifier handleSessionInvalidation] No valid context for dialog, performing direct logout and navigation.");
      await _performFullLogoutTasks();
      await navigateToLoginScreen();
    }
  }
}

final memberAuthRepositoryProvider = Provider<MemberAuthRepository>((ref) {
  return MemberAuthRepository();
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
