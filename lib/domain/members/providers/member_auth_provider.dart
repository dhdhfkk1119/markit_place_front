import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:markit_place_front/_core/utils/error_utils.dart';
import 'package:markit_place_front/domain/members/models/member.dart';
import 'package:markit_place_front/domain/members/models/session_user.dart';
import 'package:markit_place_front/domain/members/repositories/member_auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final SessionUser? user;
  final String? errorMessage;
  final bool isEmailVerifiedForRegistration;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isEmailVerifiedForRegistration = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    SessionUser? user,
    String? errorMessage,
    bool? isEmailVerifiedForRegistration,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isEmailVerifiedForRegistration:
          isEmailVerifiedForRegistration ?? this.isEmailVerifiedForRegistration,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late MemberAuthRepository _memberAuthRepository;
  final _secureStorage = const FlutterSecureStorage();
  static const _tokenKey = 'accessToken';
  static const _userMemberIdKey = 'user_member_id';
  static const _userLoginIdKey = 'user_login_id';
  static const _userNameKey = 'user_name';
  static const _userRoleKey = 'user_role'; // _userEmailKey 대신 _userRoleKey 사용

  @override
  AuthState build() {
    _memberAuthRepository = ref.watch(memberAuthRepositoryProvider);
    Future.microtask(() => _tryAutoLogin());
    return AuthState(
        status: AuthStatus.initial,
        user: null,
        errorMessage: null,
        isEmailVerifiedForRegistration: false);
  }

  Future<void> _tryAutoLogin() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await _secureStorage.read(key: _tokenKey);

    if (token != null && token.isNotEmpty) {
      final memberIdStr = await _secureStorage.read(key: _userMemberIdKey);
      final loginId = await _secureStorage.read(key: _userLoginIdKey);
      final name = await _secureStorage.read(key: _userNameKey);
      final role = await _secureStorage.read(key: _userRoleKey); // role 읽기

      if (memberIdStr != null && loginId != null && role != null) {
        // memberId, loginId, role 모두 확인
        try {
          final memberId = int.parse(memberIdStr);
          final sessionUser = SessionUser(
            memberId: memberId,
            loginId: loginId,
            name: name,
            role: role, // SessionUser 생성자에 role 전달
          );
          state = state.copyWith(
              status: AuthStatus.authenticated,
              user: sessionUser,
              isEmailVerifiedForRegistration: false);
        } catch (e) {
          await logout();
        }
      } else {
        await logout(); // 필수 정보 중 하나라도 없으면 로그아웃
      }
    } else {
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isEmailVerifiedForRegistration: false);
    }
  }

  Future<void> register(Member memberToRegister) async {
    state = state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        isEmailVerifiedForRegistration: false);
    try {
      final registeredMember =
          await _memberAuthRepository.register(memberToRegister);
      if (registeredMember != null) {
        state = state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: "회원가입 성공! 로그인해주세요.",
            isEmailVerifiedForRegistration: false);
      } else {
        state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: "회원가입 처리 중 알 수 없는 문제가 발생했습니다.");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      state =
          state.copyWith(status: AuthStatus.error, errorMessage: errorMessage);
    }
  }

  Future<void> login(String loginId, String password) async {
    state = state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        isEmailVerifiedForRegistration: state.isEmailVerifiedForRegistration);
    try {
      final loginResult = await _memberAuthRepository.login(loginId, password);

      final SessionUser? sessionUser =
          loginResult['sessionUser'] as SessionUser?;
      final String? token = loginResult['token'] as String?;

      if (sessionUser != null && token != null && token.isNotEmpty) {
        await _secureStorage.write(key: _tokenKey, value: token);
        await _secureStorage.write(
            key: _userMemberIdKey, value: sessionUser.memberId.toString());
        await _secureStorage.write(
            key: _userLoginIdKey, value: sessionUser.loginId);
        if (sessionUser.name != null) {
          await _secureStorage.write(
              key: _userNameKey, value: sessionUser.name!);
        }
        await _secureStorage.write(
            key: _userRoleKey, value: sessionUser.role); // role 저장

        state = state.copyWith(
            status: AuthStatus.authenticated,
            user: sessionUser,
            isEmailVerifiedForRegistration: false);
        print("로그인 성공 (AuthNotifier)");
      } else {
        String errorMessage = "로그인 처리 중 알 수 없는 문제가 발생했습니다 (데이터 누락).";
        if (token == null || token.isEmpty) {
          errorMessage = "로그인 응답에서 토큰을 추출하지 못했습니다.";
        } else if (sessionUser == null) {
          errorMessage = "로그인 응답에서 사용자 정보를 추출하지 못했습니다.";
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      state =
          state.copyWith(status: AuthStatus.error, errorMessage: errorMessage);
      print("로그인 실패 (AuthNotifier): $errorMessage");
    }
  }

  Future<void> signInWithNaver() async {
    state = state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        isEmailVerifiedForRegistration: false);
    try {
      final socialLoginResult = await _memberAuthRepository.signInWithNaver();

      if (socialLoginResult != null) {
        final SessionUser? sessionUser =
            socialLoginResult['sessionUser'] as SessionUser?;
        final String? token = socialLoginResult['token'] as String?;

        if (sessionUser != null && token != null && token.isNotEmpty) {
          await _secureStorage.write(key: _tokenKey, value: token);
          await _secureStorage.write(
              key: _userMemberIdKey, value: sessionUser.memberId.toString());
          await _secureStorage.write(
              key: _userLoginIdKey, value: sessionUser.loginId);
          if (sessionUser.name != null) {
            await _secureStorage.write(
                key: _userNameKey, value: sessionUser.name!);
          }
          await _secureStorage.write(
              key: _userRoleKey, value: sessionUser.role); // role 저장

          state = state.copyWith(
              status: AuthStatus.authenticated,
              user: sessionUser,
              isEmailVerifiedForRegistration: false);
          print("네이버 소셜 로그인 성공 (AuthNotifier)");
        } else {
          throw Exception("네이버 소셜 로그인 처리 중 서버 응답 데이터가 누락되었습니다.");
        }
      } else {
        state = state.copyWith(
            status: AuthStatus.unauthenticated, clearError: true);
        print("네이버 소셜 로그인이 완료되지 않았습니다 (사용자 취소 등).");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      state = state.copyWith(
          status: AuthStatus.error, errorMessage: "네이버 로그인 실패: $errorMessage");
      print("네이버 소셜 로그인 실패 (AuthNotifier): $errorMessage");
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userMemberIdKey);
    await _secureStorage.delete(key: _userLoginIdKey);
    await _secureStorage.delete(key: _userNameKey);
    await _secureStorage.delete(key: _userRoleKey); // role 삭제
    state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearError: true,
        isEmailVerifiedForRegistration: false);
  }

  void clearRegistrationSuccessMessage() {
    if (state.status == AuthStatus.unauthenticated &&
        state.errorMessage == "회원가입 성공! 로그인해주세요.") {
      state = state.copyWith(clearError: true);
    }
  }

  Future<void> requestEmailVerification(String email) async {
    try {
      await _memberAuthRepository.requestEmailVerification(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> confirmEmailVerification(String email, String code) async {
    try {
      final isVerified =
          await _memberAuthRepository.confirmEmailVerification(email, code);
      if (isVerified) {
        state = state.copyWith(
            isEmailVerifiedForRegistration: true, clearError: true);
      }
      return isVerified;
    } catch (e) {
      state = state.copyWith(isEmailVerifiedForRegistration: false);
      rethrow;
    }
  }

  void resetEmailVerificationState() {
    state = state.copyWith(isEmailVerifiedForRegistration: false);
  }

  Future<bool> checkIdAvailability(String loginId) async {
    try {
      final bool isAvailable =
          await _memberAuthRepository.checkIdAvailability(loginId);
      return isAvailable;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> refreshAccessToken() async {
    try {
      final String? newAccessToken = await _memberAuthRepository.reissueToken();
      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await _secureStorage.write(key: _tokenKey, value: newAccessToken);
        print("Access token refreshed successfully by AuthNotifier.");
        return true;
      } else {
        print(
            "Failed to refresh access token (AuthNotifier): No new token received.");
        await logout();
        return false;
      }
    } catch (e) {
      print(
          "Failed to refresh access token (AuthNotifier): ${extractErrorMessage(e)}");
      await logout();
      return false;
    }
  }
}

final memberAuthRepositoryProvider = Provider<MemberAuthRepository>((ref) {
  return MemberAuthRepository();
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
