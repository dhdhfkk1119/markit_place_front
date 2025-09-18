import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:markit_place_front/_core/utils/error_utils.dart';
import 'package:markit_place_front/domain/members/models/member.dart';
import 'package:markit_place_front/domain/members/models/session_user.dart';
import 'package:markit_place_front/domain/social_login/social_login_repository.dart';
import 'package:markit_place_front/domain/members/repositories/member_auth_repository.dart';
import 'package:markit_place_front/domain/members/repositories/email_verification_repository.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// 인증 상태를 나타내는 열거형
enum AuthStatus {
  initial, // 초기 상태
  loading, // 처리 중
  authenticated, // 인증됨
  unauthenticated, // 미인증 (로그아웃 포함)
  error, // 오류 발생
}

/// 로그인 유형을 나타내는 열거형
enum LoginType {
  none, // 특정 로그인 유형 없음 (초기, 로그아웃, 처리 중 등)
  auto, // 자동 로그인
  account, // 일반 계정(ID/PW) 로그인
  social, // 소셜 로그인 (네이버, 구글 등)
}

/// 앱의 전반적인 인증 상태를 관리하는 클래스
class AuthState {
  final AuthStatus status; // 현재 인증 상태
  final SessionUser? user; // 로그인한 사용자 정보 (인증 시)
  final String? errorMessage; // 오류 발생 시 메시지
  final bool isEmailVerifiedForRegistration; // 회원가입 시 이메일 인증 완료 여부
  final LoginType loginType; // 현재/마지막 로그인 유형

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isEmailVerifiedForRegistration = false,
    this.loginType = LoginType.none,
  });

  /// 기존 상태를 복사하여 새로운 상태 객체를 생성 (불변성 유지)
  ///
  /// [clearUser]가 true이면 사용자 정보를 null로 초기화.
  /// [clearError]가 true이면 에러 메시지를 null로 초기화.
  AuthState copyWith({
    AuthStatus? status,
    SessionUser? user,
    String? errorMessage,
    bool? isEmailVerifiedForRegistration,
    LoginType? loginType,
    bool clearUser = false, // 사용자 정보 초기화 여부
    bool clearError = false, // 에러 메시지 초기화 여부
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isEmailVerifiedForRegistration:
          isEmailVerifiedForRegistration ?? this.isEmailVerifiedForRegistration,
      loginType: loginType ?? this.loginType,
    );
  }
}

/// 인증 관련 비즈니스 로직 및 상태 관리를 담당하는 Notifier
class AuthNotifier extends Notifier<AuthState> {
  // 의존성 주입될 리포지토리 (build 메소드에서 초기화)
  late MemberAuthRepository _memberAuthRepository;
  late EmailVerificationRepository _emailVerificationRepository;
  late SocialLoginRepository _socialLoginRepository;

  // 토큰 및 사용자 정보 저장을 위한 Secure Storage
  final _secureStorage = const FlutterSecureStorage();
  // Secure Storage 키 상수
  static const _tokenKey = 'accessToken';
  static const _userMemberIdKey = 'user_member_id';
  static const _userLoginIdKey = 'user_login_id';
  static const _userNameKey = 'user_name';
  static const _userRoleKey = 'user_role';

  @override
  AuthState build() {
    // 각 리포지토리 인스턴스를 ref.watch를 통해 주입받음
    _memberAuthRepository = ref.watch(memberAuthRepositoryProvider);
    _emailVerificationRepository =
        ref.watch(emailVerificationRepositoryProvider);
    _socialLoginRepository = ref.watch(socialLoginRepositoryProvider);

    // Notifier 빌드 후 자동 로그인 시도
    Future.microtask(() => _tryAutoLogin());

    // 초기 상태 반환
    return AuthState(loginType: LoginType.none);
  }

  /// 앱 시작 시 자동 로그인을 시도하는 내부 메소드
  Future<void> _tryAutoLogin() async {
    state =
        state.copyWith(status: AuthStatus.loading, loginType: LoginType.none);
    final token = await _secureStorage.read(key: _tokenKey);

    if (token != null && token.isNotEmpty) {
      // 저장된 토큰이 있다면 사용자 정보도 불러옴
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
            name: name, // 이름은 nullable일 수 있음
            role: role,
          );
          // 모든 정보가 유효하면 인증 상태로 변경 (자동 로그인 성공)
          state = state.copyWith(
              status: AuthStatus.authenticated,
              user: sessionUser,
              loginType: LoginType.auto);
        } catch (e) {
          // 사용자 정보 파싱 오류 등 발생 시 로그아웃 처리
          print("자동 로그인 중 사용자 정보 파싱 오류: $e");
          await logout();
        }
      } else {
        // 토큰은 있으나 사용자 정보 일부 누락 시 로그아웃 처리
        print("자동 로그인 중 사용자 정보 누락, 로그아웃 처리");
        await logout();
      }
    } else {
      // 저장된 토큰이 없으면 미인증 상태로 설정
      state = state.copyWith(
          status: AuthStatus.unauthenticated, loginType: LoginType.none);
    }
  }

  /// 회원가입을 처리하는 메소드
  Future<void> register(Member memberToRegister) async {
    state = state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        loginType: LoginType.none);
    try {
      await _memberAuthRepository.register(memberToRegister);
      // 회원가입 성공 시, 로그인 페이지로 유도하기 위해 미인증 상태와 성공 메시지 설정
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: "회원가입 성공! 로그인해주세요.",
          isEmailVerifiedForRegistration: false, // 이메일 인증 상태 초기화
          loginType: LoginType.none);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: errorMessage,
          loginType: LoginType.none);
    }
  }

  /// 계정(ID/PW) 로그인을 처리하는 메소드
  Future<void> login(String loginId, String password) async {
    state = state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        loginType: LoginType.none);
    try {
      final loginResult = await _memberAuthRepository.login(loginId, password);
      final SessionUser? sessionUser =
          loginResult['sessionUser'] as SessionUser?;
      final String? token = loginResult['token'] as String?;

      if (sessionUser != null && token != null && token.isNotEmpty) {
        // 토큰 및 사용자 정보 Secure Storage에 저장
        await _secureStorage.write(key: _tokenKey, value: token);
        await _secureStorage.write(
            key: _userMemberIdKey, value: sessionUser.memberId.toString());
        await _secureStorage.write(
            key: _userLoginIdKey, value: sessionUser.loginId);
        if (sessionUser.name != null) {
          await _secureStorage.write(
              key: _userNameKey, value: sessionUser.name!);
        } else {
          await _secureStorage.delete(key: _userNameKey); // 이름이 null이면 기존 값 삭제
        }
        await _secureStorage.write(key: _userRoleKey, value: sessionUser.role);

        // 인증 상태로 변경 (계정 로그인 성공)
        state = state.copyWith(
            status: AuthStatus.authenticated,
            user: sessionUser,
            loginType: LoginType.account);
        print("로그인 성공 (AuthNotifier): ${sessionUser.loginId}");
      } else {
        // 서버 응답은 성공했으나, 필요한 데이터 (토큰 또는 사용자 정보) 누락 시
        String errorDetail = "데이터 누락";
        if (token == null || token.isEmpty) {
          errorDetail = "토큰 누락";
        } else if (sessionUser == null) {
          errorDetail = "사용자 정보 누락";
        }
        throw Exception("로그인 처리 중 서버 응답 데이터가 누락되었습니다 ($errorDetail).");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: errorMessage,
          loginType: LoginType.none);
      print("로그인 실패 (AuthNotifier): $errorMessage");
    }
  }

  /// 네이버 소셜 로그인을 처리하는 메소드
  Future<void> signInWithNaver() async {
    state = state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        loginType: LoginType.none);
    try {
      final socialLoginResult = await _socialLoginRepository.signInWithNaver();

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
          } else {
            await _secureStorage.delete(key: _userNameKey);
          }
          await _secureStorage.write(
              key: _userRoleKey, value: sessionUser.role);

          state = state.copyWith(
              status: AuthStatus.authenticated,
              user: sessionUser,
              loginType: LoginType.social);
          print("네이버 소셜 로그인 성공 (AuthNotifier): ${sessionUser.loginId}");
        } else {
          throw Exception("네이버 소셜 로그인 처리 중 서버 응답 데이터가 누락되었습니다.");
        }
      } else {
        // 사용자가 네이버 로그인 취소 등 (SDK에서 null 반환)
        state = state.copyWith(
            status: AuthStatus.unauthenticated, // 로딩 후 미인증 상태로 복귀
            clearError: true, // 에러는 없었으므로 클리어
            loginType: LoginType.none);
        print("네이버 소셜 로그인이 완료되지 않았습니다 (사용자 취소 등).");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: "네이버 로그인 실패: $errorMessage",
          loginType: LoginType.none);
      print("네이버 소셜 로그인 실패 (AuthNotifier): $errorMessage");
    }
  }

  /// 구글 소셜 로그인을 처리하는 메소드
  Future<void> signInWithGoogle() async {
    state = state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        loginType: LoginType.none);
    try {
      final socialLoginResult = await _socialLoginRepository.signInWithGoogle();

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
          } else {
            await _secureStorage.delete(key: _userNameKey);
          }
          await _secureStorage.write(
              key: _userRoleKey, value: sessionUser.role);

          state = state.copyWith(
              status: AuthStatus.authenticated,
              user: sessionUser,
              loginType: LoginType.social);
          print("구글 소셜 로그인 성공 (AuthNotifier): ${sessionUser.loginId}");
        } else {
          throw Exception("구글 소셜 로그인 처리 중 서버 응답 데이터가 누락되었습니다.");
        }
      } else {
        // 사용자가 구글 로그인 취소 등
        state = state.copyWith(
            status: AuthStatus.unauthenticated,
            clearError: true,
            loginType: LoginType.none);
        print("구글 소셜 로그인이 완료되지 않았습니다 (사용자 취소 등).");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: "구글 로그인 실패: $errorMessage",
          loginType: LoginType.none);
      print("구글 소셜 로그인 실패 (AuthNotifier): $errorMessage");
    }
  }

  /// 로그아웃을 처리하는 메소드
  Future<void> logout() async {
    state = state.copyWith(
        status: AuthStatus.loading,
        loginType: LoginType.none); // 로그아웃 시작 시 로딩 상태

    // 네이버 SDK 로그아웃 시도
    try {
      await FlutterNaverLogin.logOut();
      print("[AuthNotifier] Naver SDK logout successful.");
    } catch (e) {
      print("[AuthNotifier] Error during Naver SDK logout: $e");
    }

    // 구글 SDK 로그아웃 시도
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
        print("[AuthNotifier] Google SDK logout successful.");
      }
    } catch (e) {
      print("[AuthNotifier] Error during Google SDK logout: $e");
    }

    // Secure Storage에서 토큰 및 사용자 정보 삭제
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userMemberIdKey);
    await _secureStorage.delete(key: _userLoginIdKey);
    await _secureStorage.delete(key: _userNameKey);
    await _secureStorage.delete(key: _userRoleKey);

    // 상태를 미인증으로 변경하고 사용자 정보 및 에러 메시지 초기화
    state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true, // 사용자 정보 초기화
        clearError: true, // 에러 메시지 초기화
        isEmailVerifiedForRegistration: false, // 이메일 인증 상태 초기화
        loginType: LoginType.none // 로그인 타입 초기화
        );
    print("[AuthNotifier] User logged out, local data cleared.");
  }

  /// 회원가입 성공 메시지 ("회원가입 성공! 로그인해주세요.")를 상태에서 제거하는 메소드
  /// 주로 회원가입 후 자동 로그인 시도 전에 호출됨
  void clearRegistrationSuccessMessage() {
    if (state.status == AuthStatus.unauthenticated &&
        state.errorMessage == "회원가입 성공! 로그인해주세요.") {
      state = state.copyWith(clearError: true, loginType: LoginType.none);
    }
  }

  /// 회원가입 시 이메일 인증 코드 발송을 요청하는 메소드
  Future<void> requestEmailVerification(String email) async {
    // API 호출은 Repository에 위임하고, 성공/실패는 Repository에서 Exception으로 처리
    try {
      await _emailVerificationRepository.requestEmailVerification(email);
    } catch (e) {
      // Repository에서 발생한 예외를 그대로 상위로 전달하여 UI단에서 처리하도록 함
      rethrow;
    }
  }

  /// 회원가입 시 이메일 인증 코드를 확인하는 메소드
  /// 성공 시 `isEmailVerifiedForRegistration` 상태를 true로 변경
  Future<bool> confirmEmailVerification(String email, String code) async {
    try {
      final isVerified = await _emailVerificationRepository
          .confirmEmailVerification(email, code);
      if (isVerified) {
        state = state.copyWith(
            isEmailVerifiedForRegistration: true, // 이메일 인증 완료 상태로 변경
            clearError: true, // 이전 에러가 있었다면 클리어
            loginType: LoginType.none // 이메일 인증은 특정 로그인 타입과 무관
            );
      } else {
        // Repository에서 인증 실패 시 false를 반환하거나 Exception을 던질 수 있음
        // 여기서는 false 반환 시 해당 상태를 유지 (Exception은 catch 블록에서 처리)
        state = state.copyWith(
            isEmailVerifiedForRegistration: false, loginType: LoginType.none);
      }
      return isVerified;
    } catch (e) {
      state = state.copyWith(
          isEmailVerifiedForRegistration: false, loginType: LoginType.none);
      rethrow; // 예외를 UI단으로 전달
    }
  }

  /// 회원가입 과정에서 사용된 이메일 인증 관련 상태를 초기화하는 메소드
  void resetEmailVerificationState() {
    state = state.copyWith(
        isEmailVerifiedForRegistration: false, loginType: LoginType.none);
  }

  /// 아이디 중복 확인을 요청하는 메소드
  Future<bool> checkIdAvailability(String loginId) async {
    try {
      final bool isAvailable =
          await _memberAuthRepository.checkIdAvailability(loginId);
      return isAvailable;
    } catch (e) {
      rethrow;
    }
  }

  /// 액세스 토큰 재발급을 시도하는 메소드
  /// 성공 시 새로운 액세스 토큰을 Secure Storage에 저장하고 true 반환.
  /// 실패 시 (네트워크 오류, 서버 오류, 유효하지 않은 리프레시 토큰 등) 로그아웃 처리 후 false 반환.
  Future<bool> refreshAccessToken() async {
    try {
      final String? newAccessToken = await _memberAuthRepository.reissueToken();
      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await _secureStorage.write(key: _tokenKey, value: newAccessToken);
        print("[AuthNotifier] Access token refreshed successfully.");
        return true;
      } else {
        // 새 액세스 토큰이 없거나 비어있는 경우 (서버 로직 오류 또는 비정상 응답)
        print(
            "[AuthNotifier] Failed to refresh access token: New access token is null or empty. Logging out.");
        await logout(); // 이 경우, 사용자 세션이 유효하지 않다고 판단하여 로그아웃 처리
        return false;
      }
    } catch (e) {
      // 토큰 재발급 과정에서 예외 발생 (네트워크, 서버 에러, 만료된 리프레시 토큰 등)
      print(
          "[AuthNotifier] Failed to refresh access token: ${extractErrorMessage(e)}. Logging out.");
      await logout(); // 재발급 실패는 로그아웃으로 이어짐
      return false;
    }
  }
}

// --- Riverpod Provider 정의 ---

/// MemberAuthRepository 인스턴스를 제공하는 Provider
final memberAuthRepositoryProvider = Provider<MemberAuthRepository>((ref) {
  return MemberAuthRepository();
});

/// EmailVerificationRepository 인스턴스를 제공하는 Provider
final emailVerificationRepositoryProvider =
    Provider<EmailVerificationRepository>((ref) {
  return EmailVerificationRepository();
});

/// SocialLoginRepository 인스턴스를 제공하는 Provider
final socialLoginRepositoryProvider = Provider<SocialLoginRepository>((ref) {
  return SocialLoginRepository();
});

/// AuthNotifier 인스턴스와 AuthState를 제공하는 NotifierProvider
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
