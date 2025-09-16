import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:markit_place_front/_core/utils/error_utils.dart'; // error_utils.dart 임포트
import 'package:markit_place_front/domain/members/models/member.dart';
import 'package:markit_place_front/domain/members/models/session_user.dart';
import 'package:markit_place_front/domain/members/repositories/member_auth_repository.dart'; // MemberAuthRepository 임포트
// import 'package:markit_place_front/domain/repositories/auth_repository/user_repository.dart'; // UserRepository 관련 코드는 주석 처리 또는 삭제

enum AuthStatus {
  initial, // 초기 상태
  loading, // 로딩 중
  authenticated, // 인증됨 (로그인 성공)
  unauthenticated, // 미인증 (로그아웃 또는 초기)
  error, // 오류 발생
}

// 인증 상태를 나타내는 클래스
class AuthState {
  final AuthStatus status; // 현재 인증 상태 (enum)
  final SessionUser? user; // 로그인한 사용자 정보 (nullable)
  final String? errorMessage; // 오류 발생 시 메시지 (nullable)
  final bool isEmailVerifiedForRegistration; // 회원가입 시 이메일 인증 완료 여부

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isEmailVerifiedForRegistration = false, // 기본값은 false
  });

  // AuthState 객체를 복사하여 일부 값만 변경하는 메소드
  AuthState copyWith({
    AuthStatus? status,
    SessionUser? user,
    String? errorMessage,
    bool? isEmailVerifiedForRegistration, // 이메일 인증 상태 업데이트용
    bool clearUser = false, // 사용자 정보를 명시적으로 null로 설정할지 여부
    bool clearError = false, // 에러 메시지를 명시적으로 null로 설정할지 여부
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
  late MemberAuthRepository
      _memberAuthRepository; // 직접 사용할 MemberAuthRepository
  final _secureStorage = const FlutterSecureStorage();
  static const _tokenKey = 'accessToken';
  static const _userMemberIdKey = 'user_member_id';
  static const _userLoginIdKey = 'user_login_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  // static const _userRoleKey = 'user_role'; // Role 관련 키 주석 처리

  @override
  AuthState build() {
    _memberAuthRepository =
        ref.watch(memberAuthRepositoryProvider); // MemberAuthRepository 주입
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
      // final role = await _secureStorage.read(key: _userRoleKey); // Role 읽기 주석 처리

      // if (memberIdStr != null && loginId != null && role != null) { // role 조건 제거
      if (memberIdStr != null && loginId != null) {
        try {
          final memberId = int.parse(memberIdStr);
          final sessionUser = SessionUser(
            memberId: memberId,
            loginId: loginId,
            name: name,
            // role: role, // SessionUser 생성 시 role 전달 주석 처리
          );
          state = state.copyWith(
              status: AuthStatus.authenticated,
              user: sessionUser,
              isEmailVerifiedForRegistration: false);
        } catch (e) {
          await logout();
        }
      } else {
        await logout();
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
        isEmailVerifiedForRegistration: false);
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
        // await _secureStorage.write(key: _userRoleKey, value: sessionUser.role); // Role 저장 주석 처리

        state = state.copyWith(
            status: AuthStatus.authenticated,
            user: sessionUser,
            isEmailVerifiedForRegistration: false);
        print("로그인 성공 (AuthNotifier -> MemberAuthRepository 직접 호출)");
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

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userMemberIdKey);
    await _secureStorage.delete(key: _userLoginIdKey);
    await _secureStorage.delete(key: _userNameKey);
    await _secureStorage.delete(key: _userEmailKey);
    // await _secureStorage.delete(key: _userRoleKey); // Role 삭제 주석 처리
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
            isEmailVerifiedForRegistration: true,
            status: AuthStatus.initial,
            clearError: true);
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
}

final memberAuthRepositoryProvider = Provider<MemberAuthRepository>((ref) {
  return MemberAuthRepository();
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
