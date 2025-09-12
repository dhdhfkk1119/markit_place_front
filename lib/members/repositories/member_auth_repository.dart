import 'package:dio/dio.dart'; // Response 타입을 위해 추가

// import '../domains/ui_models/member_register_request_ui_model.dart'; // 이미 삭제됨
import '../domains/member.dart'; // Member 모델 import
// import '../domains/ui_models/member_register_response_ui_model.dart'; // 삭제 또는 주석 처리
// DTO import는 실제 구현체에서 필요할 수 있으나, 여기서는 Member? 반환이므로 직접 필요 X

abstract class MemberAuthRepository {
  Future<Member?> register(
      // 반환 타입을 Member? 로 변경
      Member memberToRegister);

  // 로그인 메서드 추가 (id, password 직접 받고 Response 반환)
  Future<Response> login(String loginId, String password);

  // 향후 UI 모델 기반 로그인 (선택적)
  // Future<MemberLoginResponseUiModel> loginWithUiModel(MemberLoginRequestUiModel requestUiModel);

  // Future<SocialLoginResponseUiModel> socialLogin(SocialLoginRequestUiModel requestUiModel);
  // Future<void> logout();
  // Future<void> changePassword(ChangePasswordRequestUiModel requestUiModel);
  // ... 등등
}
