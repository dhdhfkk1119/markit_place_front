import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../_core/utils/error_utils.dart';
import '../../../_core/utils/validator_util.dart';
// import '../models/member.dart'; // 삭제
import '../models/session_user.dart';
import '../repositories/member_auth_repository.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'profile_provider.dart';
import '../../social_login/social_login_provider.dart';
// import 'email_verification_provider.dart'; // AuthNotifier에서 직접 사용하지 않으므로 삭제

// MemberLoginFormModel 클래스
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

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  registrationSuccess, // 이 상태는 RegisterNotifier 쪽으로 옮겨가거나 다른 방식으로 처리될 수 있음.
  // AuthNotifier가 직접 registrationSuccess 상태를 관리할 필요가 없을 수 있음.
  // 하지만 clearRegistrationSuccessMessage가 있으므로 일단 유지.
}

enum LoginType {
  none,
  auto,
  account,
  social,
}

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

  final _secureStorage = const FlutterSecureStorage();
  static const String tokenKey = 'accessToken';
  static const String userMemberIdKey = 'user_member_id';
  static const String userLoginIdKey = 'user_login_id';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';
  static const String userRoleKey = 'user_role';
  static const String userProfileImageUrlKey = 'user_profile_image_url';

  @override
  AuthState build() {
    _memberAuthRepository = ref.watch(memberAuthRepositoryProvider);
    Future.microtask(() => _tryAutoLogin());
    return AuthState(loginFormModel: const MemberLoginFormModel());
  }

  ProfileNotifier get _profileNotifierReader =>
      ref.read(profileNotifierProvider.notifier);
  SocialLoginNotifier get _socialLoginNotifierReader =>
      ref.read(socialLoginNotifierProvider.notifier);
  // EmailVerificationNotifier get _emailVerificationNotifierReader => // 삭제
  //     ref.read(emailVerificationNotifierProvider.notifier);

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

  void updateUserAndAuthStatus(
      SessionUser? user, AuthStatus status, LoginType loginType,
      {String? errorMessage}) {
    if (user == null && status == AuthStatus.authenticated) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          loginType: LoginType.none,
          user: null,
          errorMessage: errorMessage ?? state.errorMessage);
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
        status: AuthStatus.authenticated, errorMessage: errorMessage);
  }

  Future<void> storeSessionUser(SessionUser sessionUser, String token) async {
    await _secureStorage.write(key: tokenKey, value: token);
    await _secureStorage.write(
        key: userMemberIdKey, value: sessionUser.memberId.toString());
    await _secureStorage.write(key: userRoleKey, value: sessionUser.role);
    if (sessionUser.loginId != null) {
      await _secureStorage.write(
          key: userLoginIdKey, value: sessionUser.loginId!);
    } else {
      await _secureStorage.delete(key: userLoginIdKey);
    }
    if (sessionUser.email != null) {
      await _secureStorage.write(key: userEmailKey, value: sessionUser.email!);
    } else {
      await _secureStorage.delete(key: userEmailKey);
    }
    if (sessionUser.name != null) {
      await _secureStorage.write(key: userNameKey, value: sessionUser.name!);
    } else {
      await _secureStorage.delete(key: userNameKey);
    }
    if (sessionUser.profileImageUrl != null) {
      await _secureStorage.write(
          key: userProfileImageUrlKey, value: sessionUser.profileImageUrl!);
    } else {
      await _secureStorage.delete(key: userProfileImageUrlKey);
    }
  }

  Future<void> _tryAutoLogin() async {
    setLoading();
    final token = await _secureStorage.read(key: tokenKey);
    if (token != null && token.isNotEmpty) {
      final memberIdStr = await _secureStorage.read(key: userMemberIdKey);
      final String? loginId = await _secureStorage.read(key: userLoginIdKey);
      final String? email = await _secureStorage.read(key: userEmailKey);
      final String? name = await _secureStorage.read(key: userNameKey);
      final String? role = await _secureStorage.read(key: userRoleKey);
      final String? profileImageUrl =
          await _secureStorage.read(key: userProfileImageUrlKey);

      if (memberIdStr != null && role != null) {
        try {
          final memberId = int.parse(memberIdStr);
          final sessionUser = SessionUser(
              memberId: memberId,
              loginId: loginId,
              email: email,
              name: name,
              role: role,
              profileImageUrl: profileImageUrl);
          updateUserAndAuthStatus(
              sessionUser, AuthStatus.authenticated, LoginType.auto);
          await _profileNotifierReader.fetchMyProfileAndUpdateAuthNotifier(
              showLoading: false);
        } catch (e) {
          print("자동 로그인 중 사용자 정보 파싱 또는 프로필 조회 오류: $e");
          await logout();
        }
      } else {
        print("자동 로그인 중 필수 사용자 정보(memberId 또는 role) 누락, 로그아웃 처리");
        await logout();
      }
    } else {
      updateUserAndAuthStatus(null, AuthStatus.unauthenticated, LoginType.none);
    }
  }

  Future<void> login() async {
    if (!validateLoginForm()) {
      return;
    }
    setLoading();
    try {
      final loginResult = await _memberAuthRepository.login(
          state.loginFormModel.loginInput, state.loginFormModel.password);
      final SessionUser? serverUser =
          loginResult['sessionUser'] as SessionUser?;
      final String? token = loginResult['token'] as String?;
      if (serverUser != null && token != null && token.isNotEmpty) {
        await storeSessionUser(serverUser, token);
        updateUserAndAuthStatus(
            serverUser, AuthStatus.authenticated, LoginType.account);
        await _profileNotifierReader.fetchMyProfileAndUpdateAuthNotifier(
            showLoading: false);
        resetLoginForm();
      } else {
        throw Exception("로그인 처리 중 서버 응답 데이터가 누락되었습니다.");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      setError(errorMessage);
    }
  }

  Future<void> logout() async {
    setLoading();
    try {
      await FlutterNaverLogin.logOut();
    } catch (e) {
      print("[AuthNotifier] Error during Naver SDK logout: $e");
    }
    await _socialLoginNotifierReader.signOutFromGoogleSdk();

    await _secureStorage.delete(key: tokenKey);
    await _secureStorage.delete(key: userMemberIdKey);
    await _secureStorage.delete(key: userLoginIdKey);
    await _secureStorage.delete(key: userEmailKey);
    await _secureStorage.delete(key: userNameKey);
    await _secureStorage.delete(key: userRoleKey);
    await _secureStorage.delete(key: userProfileImageUrlKey);

    updateUserAndAuthStatus(null, AuthStatus.unauthenticated, LoginType.none);
    state = state.copyWith(clearError: true);
    print("[AuthNotifier] User logged out, local data cleared.");
    resetLoginForm();
  }

  Future<bool> refreshAccessToken() async {
    try {
      final String? newAccessToken = await _memberAuthRepository.reissueToken();
      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await _secureStorage.write(key: tokenKey, value: newAccessToken);
        await _profileNotifierReader.fetchMyProfileAndUpdateAuthNotifier(
            showLoading: false);
        return true;
      } else {
        print(
            "[AuthNotifier] Failed to refresh access token: New access token is null or empty. Logging out.");
        await logout();
        return false;
      }
    } catch (e) {
      print(
          "[AuthNotifier] Failed to refresh access token: ${extractErrorMessage(e)}. Logging out.");
      await logout();
      return false;
    }
  }

  // Future<bool> checkIdAvailability(String loginId) async { // 삭제
  //   // ...
  // }

  // Future<void> register(Member memberToRegister) async { // 삭제
  //   // ...
  // }

  void clearRegistrationSuccessMessage() {
    if (state.status == AuthStatus.registrationSuccess) {
      state =
          state.copyWith(status: AuthStatus.unauthenticated, clearError: true);
    }
  }
}

// MemberAuthRepository Provider 정의는 그대로 유지
final memberAuthRepositoryProvider = Provider<MemberAuthRepository>((ref) {
  return MemberAuthRepository();
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
