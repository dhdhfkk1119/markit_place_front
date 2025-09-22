import 'dart:convert'; // jsonEncode를 사용하기 위해 추가
import 'package:flutter/material.dart'; // AlertDialog를 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../_core/sessions/session_provider.dart'; // 삭제
// import '../../../_core/sessions/session_repository.dart'; // 삭제
import '../../../_core/utils/error_utils.dart';
import '../../../_core/utils/validator_util.dart';
import '../models/session_user.dart'; // 경로 올바름 (이미 ../models/session_user.dart 로 사용중이었음)
import '../repositories/member_auth_repository.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'profile_provider.dart';
import '../../social_login/social_login_provider.dart';
import '../../../main.dart';

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

  @override
  AuthState build() {
    // MemberAuthRepository 인스턴스를 Provider를 통해 가져옵니다.
    _memberAuthRepository = ref.watch(memberAuthRepositoryProvider);
    // 앱 시작 시 자동 로그인 시도
    Future.microtask(() => _tryAutoLogin());
    return AuthState(loginFormModel: const MemberLoginFormModel());
  }

  // ProfileNotifier 및 SocialLoginNotifier에 대한 참조는 그대로 유지
  ProfileNotifier get _profileNotifierReader =>
      ref.read(profileNotifierProvider.notifier);
  SocialLoginNotifier get _socialLoginNotifierReader =>
      ref.read(socialLoginNotifierProvider.notifier);

  // --- 기존 로그인 폼 관련 로직 (변경 없음) ---
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

  // --- 세션 관리 및 상태 업데이트 로직 (MemberAuthRepository 직접 사용) ---
  Future<void> updateUserAndAuthStatus(
    SessionUser? user,
    AuthStatus status,
    LoginType loginType, {
    String? newToken, // 로그인 또는 토큰 갱신 시 받은 새 토큰
    String? errorMessage,
  }) async {
    print(
        "[AuthNotifier updateUserAndAuthStatus] User: ${user?.name}, Status: $status, LoginType: $loginType, NewToken: ${newToken != null}, Error: $errorMessage");

    // 인증된 상태로 변경하는데 사용자 정보가 없는 경우, 비인증 상태로 강제 전환 및 세션 클리어
    if (user == null && status == AuthStatus.authenticated) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          loginType: LoginType.none,
          clearUser: true,
          errorMessage: errorMessage ?? "세션 또는 사용자 정보가 유효하지 않습니다.");
      await _memberAuthRepository
          .clearSessionData(); // MemberAuthRepository의 세션 클리어 사용
      return;
    }

    // 상태 업데이트
    state = state.copyWith(
        user: user,
        status: status,
        loginType: loginType,
        clearError: errorMessage == null, // 에러 메시지가 없으면 기존 에러 클리어
        errorMessage: errorMessage,
        loginFormModel: (status == AuthStatus.authenticated ||
                status == AuthStatus.unauthenticated)
            ? const MemberLoginFormModel() // 로그인/로그아웃 성공 시 폼 초기화
            : state.loginFormModel);

    // 인증 성공 시, 사용자 정보와 토큰을 SecureStorage에 저장
    if (state.status == AuthStatus.authenticated && state.user != null) {
      try {
        String? tokenToStore;
        if (newToken != null && newToken.isNotEmpty) {
          tokenToStore = newToken;
        } else {
          // 기존 토큰을 사용해야 하는 경우 (예: 자동 로그인 시 프로필 정보만 업데이트)
          tokenToStore = await _memberAuthRepository.getAccessToken();
        }

        if (tokenToStore != null && tokenToStore.isNotEmpty) {
          await _memberAuthRepository.storeSessionData(
              state.user!, tokenToStore); // MemberAuthRepository의 세션 저장 사용
          print(
              "[AuthNotifier] Session updated and stored for user ID: ${state.user!.memberId}. Token presence: ${tokenToStore.isNotEmpty}");
        } else {
          // 저장할 토큰이 없는 심각한 상황 (이론적으로 발생하기 어려움, 특히 로그인 직후에는 newToken이 있어야 함)
          print(
              "[AuthNotifier updateUserAndAuthStatus] Critical: Token to store is null or empty. User: ${state.user!.memberId}. Forcing logout.");
          if (loginType == LoginType.account || loginType == LoginType.social) {
            // 이 경우, _performFullLogoutTasks를 호출하여 로그아웃 처리
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
      loginType: LoginType.none, // 에러 발생 시 로그인 타입 초기화
    );
  }

  // 인증된 상태에서 발생하는 오류 (예: 프로필 업데이트 실패) 처리용
  void setErrorOnAuthenticated(String errorMessage) {
    state = state.copyWith(
        status: AuthStatus.authenticated, // 상태는 유지하되
        errorMessage: errorMessage, // 에러 메시지만 설정
        clearError: false);
  }

  // --- 로그인/로그아웃 핵심 로직 (MemberAuthRepository 직접 사용) ---
  Future<void> _tryAutoLogin() async {
    setLoading();
    print("[AuthNotifier _tryAutoLogin] Attempting...");
    final String? token = await _memberAuthRepository
        .getAccessToken(); // MemberAuthRepository 직접 사용
    if (token != null && token.isNotEmpty) {
      final SessionUser? storedUser = await _memberAuthRepository
          .getStoredUser(); // MemberAuthRepository 직접 사용
      if (storedUser != null) {
        try {
          // 저장된 사용자로 인증 상태 업데이트 (토큰은 이미 있으므로 newToken 전달 안함)
          await updateUserAndAuthStatus(
              storedUser, AuthStatus.authenticated, LoginType.auto);
          if (state.status == AuthStatus.authenticated) {
            print(
                "[AuthNotifier] Auto login successful. User: ${state.user?.name}. Fetching profile...");
            // 자동 로그인 성공 시 프로필 정보 최신화
            await _profileNotifierReader.fetchMyProfileAndUpdateAuthNotifier(
                showLoading: false);
          }
        } catch (e) {
          // 자동 로그인 과정 (프로필 조회 또는 세션 재저장 등)에서 오류 발생 시 전체 로그아웃
          print(
              "[AuthNotifier _tryAutoLogin] Error during auto login process (update/store session or profile fetch): $e");
          await _performFullLogoutTasks(
              isErrorLogout: true, logoutMessage: "자동 로그인 중 오류 발생");
        }
      } else {
        // 토큰은 있지만 사용자 정보가 없는 경우 (비정상 상태), 세션 클리어 및 로그아웃
        print(
            "[AuthNotifier _tryAutoLogin] Token found but stored user is null. Performing full logout.");
        await _performFullLogoutTasks(
            isErrorLogout: true, logoutMessage: "저장된 사용자 정보 오류");
      }
    } else {
      // 토큰이 없는 경우, 비인증 상태로 설정
      print(
          "[AuthNotifier _tryAutoLogin] No token found, setting to unauthenticated.");
      await updateUserAndAuthStatus(
          null, AuthStatus.unauthenticated, LoginType.none);
    }
  }

  Future<void> login() async {
    if (!validateLoginForm()) {
      return; // 폼 유효성 검사 실패
    }
    setLoading();
    print(
        "[AuthNotifier login] Attempting with input: ${state.loginFormModel.loginInput}");
    try {
      // MemberAuthRepository의 login 메소드 사용
      final loginResult = await _memberAuthRepository.login(
          state.loginFormModel.loginInput, state.loginFormModel.password);
      final SessionUser? serverUser =
          loginResult['sessionUser'] as SessionUser?;
      final String? token = loginResult['token'] as String?;

      if (serverUser != null && token != null && token.isNotEmpty) {
        // 로그인 성공 시 사용자 정보와 새 토큰으로 상태 업데이트
        await updateUserAndAuthStatus(
            serverUser, AuthStatus.authenticated, LoginType.account,
            newToken: token);
        if (state.status == AuthStatus.authenticated) {
          print(
              "[AuthNotifier] Account login successful. User: ${state.user?.name}. Fetching profile...");
          // 로그인 성공 후 프로필 정보 가져오기
          await _profileNotifierReader.fetchMyProfileAndUpdateAuthNotifier(
              showLoading: false);
        }
        resetLoginForm(); // 로그인 성공 후 폼 초기화
      } else {
        // 서버 응답은 성공했으나, 사용자 정보 또는 토큰이 누락된 경우
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

  /// 전체 로그아웃 처리 (소셜 SDK 로그아웃, SecureStorage 클리어, 상태 업데이트)
  Future<void> _performFullLogoutTasks(
      {bool isErrorLogout = false, String? logoutMessage}) async {
    if (!isErrorLogout) setLoading(); // 일반 로그아웃 시에만 로딩 상태 표시
    print(
        "[AuthNotifier _performFullLogoutTasks] Initiated. ErrorLogout: $isErrorLogout. Message: $logoutMessage");

    // 1. 소셜 로그인 SDK 로그아웃 (필요시)
    try {
      if (await FlutterNaverLogin.isLoggedIn) {
        await FlutterNaverLogin.logOut();
        print("[AuthNotifier] Naver SDK logout successful.");
      }
      // Google 로그아웃은 SocialLoginNotifier를 통해 수행 (의존성 유지)
      await _socialLoginNotifierReader.signOutFromGoogleSdk();
      print(
          "[AuthNotifier] Google SDK sign out attempt via SocialLoginNotifier.");
    } catch (e) {
      print(
          "[AuthNotifier _performFullLogoutTasks] Error during social SDK logout: $e");
      // 소셜 SDK 로그아웃 실패가 전체 로그아웃을 막아서는 안 됨.
    }

    // 2. SecureStorage에서 세션 데이터 삭제 (MemberAuthRepository 사용)
    await _memberAuthRepository.clearSessionData();
    print(
        "[AuthNotifier _performFullLogoutTasks] Session cleared from repository (SecureStorage).");

    // 3. 앱 상태를 비인증으로 변경
    // 에러로 인한 로그아웃 시 기존 에러 메시지를 유지하거나, 전달된 logoutMessage 사용
    String finalErrorMessage =
        (isErrorLogout ? state.errorMessage ?? logoutMessage : logoutMessage) ??
            "로그아웃되었습니다.";
    await updateUserAndAuthStatus(
        null, AuthStatus.unauthenticated, LoginType.none,
        errorMessage: finalErrorMessage);
    print(
        "[AuthNotifier _performFullLogoutTasks] State updated to unauthenticated. Logout completed.");
    resetLoginForm(); // 로그아웃 후 로그인 폼 초기화
  }

  /// 사용자 요청에 의한 로그아웃
  Future<void> logout() async {
    print("[AuthNotifier logout] Logout requested by user.");
    await _performFullLogoutTasks(logoutMessage: "성공적으로 로그아웃되었습니다.");
  }

  /// 세션 만료 또는 유효하지 않은 토큰 감지 시 처리 (Dio 인터셉터에서 호출됨)
  Future<void> handleSessionInvalidation(String serverMessage) async {
    print(
        "[AuthNotifier handleSessionInvalidation] Handling session invalidation with server message: $serverMessage");

    // 현재 네비게이터 컨텍스트 가져오기
    final currentContext = navigatorKey.currentContext;

    // 사용자에게 알림 표시 후 로그아웃 및 로그인 화면 이동
    if (currentContext != null && currentContext.mounted) {
      await showDialog(
        context: currentContext,
        barrierDismissible: false, // 사용자가 임의로 닫지 못하도록 설정
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text("세션 만료 알림", style: TextStyle(fontFamily: "CookieRun")),
            content:
                Text(serverMessage, style: TextStyle(fontFamily: "CookieRun")),
            actions: <Widget>[
              TextButton(
                child: Text("확인", style: TextStyle(fontFamily: "CookieRun")),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // 대화상자 닫기
                },
              ),
            ],
          );
        },
      );
    } else {
      // 대화상자를 표시할 유효한 컨텍스트가 없는 경우 (드문 경우)
      print(
          "[AuthNotifier handleSessionInvalidation] No valid context to show dialog. Proceeding with direct logout.");
    }

    // 알림 후 전체 로그아웃 처리 (에러로 인한 로그아웃으로 간주)
    await _performFullLogoutTasks(
        isErrorLogout: true, logoutMessage: serverMessage);

    // 로그인 화면으로 강제 이동
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/social-login', (route) => false);
    print(
        "[AuthNotifier handleSessionInvalidation] Navigated to /social-login screen.");
  }

  /// 프로필 업데이트 등으로 SessionUser 정보가 변경되었을 때 AuthNotifier의 상태를 직접 갱신하는 메소드
  Future<void> refreshSessionUser(SessionUser updatedUser) async {
    if (state.status == AuthStatus.authenticated && state.user != null) {
      // 현재 토큰은 그대로 사용하고 사용자 정보만 업데이트
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

// MemberAuthRepository를 제공하는 Provider (변경 없음)
final memberAuthRepositoryProvider = Provider<MemberAuthRepository>((ref) {
  return MemberAuthRepository();
});

// AuthNotifier를 제공하는 Provider (변경 없음)
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
