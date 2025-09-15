import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:markit_place_front/_core/utils/error_utils.dart'; // error_utils.dart 임포트
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

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    SessionUser? user,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late MemberAuthRepository _memberAuthRepository;
  final _secureStorage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userMemberIdKey = 'user_member_id';
  static const _userLoginIdKey = 'user_login_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userRoleKey = 'user_role';

  @override
  AuthState build() {
    _memberAuthRepository = ref.watch(memberAuthRepositoryProvider);
    Future.microtask(() => _tryAutoLogin());
    return AuthState();
  }

  Future<void> _tryAutoLogin() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await _secureStorage.read(key: _tokenKey);

    if (token != null && token.isNotEmpty) {
      final memberIdStr = await _secureStorage.read(key: _userMemberIdKey);
      final loginId = await _secureStorage.read(key: _userLoginIdKey);
      final name = await _secureStorage.read(key: _userNameKey);
      final role = await _secureStorage.read(key: _userRoleKey);

      if (memberIdStr != null && loginId != null && role != null) {
        try {
          final memberId = int.parse(memberIdStr);
          final sessionUser = SessionUser(
            memberId: memberId,
            loginId: loginId,
            name: name,
            role: role,
          );
          state = state.copyWith(
              status: AuthStatus.authenticated, user: sessionUser);
        } catch (e) {
          // _tryAutoLogin 실패 시에도 에러 메시지를 남길 수 있지만, 보통은 자동 로그아웃 처리
          await logout(); // 여기서 logout은 unauthenticated 상태로 만들고 에러 메시지를 초기화함
        }
      } else {
        await logout();
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> register(Member memberToRegister) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final registeredMember =
          await _memberAuthRepository.register(memberToRegister);
      if (registeredMember != null) {
        state = state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: "회원가입 성공! 로그인해주세요.");
      } else {
        // Repository에서 Member?를 반환하고 null을 반환한 경우는 이제 없을 것으로 예상 (Exception을 throw하므로)
        // 만약을 위해 남겨두거나, Repository가 항상 Exception을 throw하도록 완전히 신뢰한다면 이 else 블록 제거 가능
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
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final loginResult = await _memberAuthRepository.login(loginId, password);

      final SessionUser sessionUser = loginResult['sessionUser'] as SessionUser;
      final String token = loginResult['token'] as String;

      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(
          key: _userMemberIdKey, value: sessionUser.memberId.toString());
      await _secureStorage.write(
          key: _userLoginIdKey, value: sessionUser.loginId);
      if (sessionUser.name != null) {
        await _secureStorage.write(key: _userNameKey, value: sessionUser.name!);
      }
      await _secureStorage.write(key: _userRoleKey, value: sessionUser.role);

      state =
          state.copyWith(status: AuthStatus.authenticated, user: sessionUser);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      state =
          state.copyWith(status: AuthStatus.error, errorMessage: errorMessage);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userMemberIdKey);
    await _secureStorage.delete(key: _userLoginIdKey);
    await _secureStorage.delete(key: _userNameKey);
    await _secureStorage.delete(key: _userEmailKey);
    await _secureStorage.delete(key: _userRoleKey);
    state = state.copyWith(
        status: AuthStatus.unauthenticated, clearUser: true, clearError: true);
  }

  void clearRegistrationSuccessMessage() {
    if (state.status == AuthStatus.unauthenticated &&
        state.errorMessage == "회원가입 성공! 로그인해주세요.") {
      state = state.copyWith(clearError: true);
    }
  }
}

final memberAuthRepositoryProvider = Provider<MemberAuthRepository>((ref) {
  return MemberAuthRepository();
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
