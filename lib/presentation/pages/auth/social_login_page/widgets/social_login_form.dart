import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/size.dart';
import '../../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../../../domain/social_login/social_login_provider.dart'; // 수정: SocialLoginNotifier 사용 위해 추가
import '../../../../widgets/custom_button_large.dart';
import '../../../../widgets/custom_link_grey.dart';
import '../../../../widgets/snackbar_util.dart';

class SocialLoginForm extends ConsumerWidget {
  const SocialLoginForm({super.key});

  /// 소셜 로그인 아이콘을 생성하는 위젯 빌더 메소드
  Widget _buildSocialIcon(BuildContext context,
      {required String iconAssetPath,
      required VoidCallback onPressed,
      double iconSize = 48.0}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(iconSize / 2 + xSmall),
      child: Padding(
        padding: const EdgeInsets.all(xSmall),
        child: SvgPicture.asset(
          iconAssetPath,
          height: iconSize,
          width: iconSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AuthState 리스닝은 그대로 유지 (SocialLoginNotifier가 AuthNotifier 상태를 변경하므로)
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated &&
          previous?.status != AuthStatus.authenticated) {
        if (next.loginType == LoginType.social) {
          String successMessage = "소셜 로그인 성공!";
          // TODO: 향후 확장 시, next.user.loginId를 분석하여 특정 소셜 서비스(구글, 네이버)별 메시지 차별화 가능
          SnackBarUtil.showSuccess(context, successMessage);
        }
        Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
      }
      // ==== 에러 상태 처리 로직 (동일하게 AuthNotifier의 errorMessage 사용) ====
      else if (next.status == AuthStatus.error &&
          (previous?.status != AuthStatus.error ||
              previous?.errorMessage != next.errorMessage)) {
        final errorMessage = next.errorMessage ?? "소셜 로그인에 실패했습니다.";

        if (errorMessage.contains("이미 사용 중인 이메일입니다")) {
          String dialogTitle = "로그인 실패";
          String dialogContent =
              "선택하신 소셜 계정의 이메일이 이미 다른 방식으로 가입되어 있습니다.\n\n기존 방식으로 로그인하시거나, 다른 소셜 계정을 이용해주세요.";

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: Text(dialogTitle),
                content: Text(dialogContent),
                actions: <Widget>[
                  TextButton(
                    child: const Text('확인'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      // AuthNotifier의 에러 상태 초기화 (필요시 AuthNotifier에 clearError 메소드 구현)
                      // ref.read(authNotifierProvider.notifier).clearError();
                    },
                  ),
                  TextButton(
                    child: const Text('다른 Google 계정 선택'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      // 수정: socialLoginNotifierProvider 사용
                      ref
                          .read(socialLoginNotifierProvider.notifier)
                          .trySignInWithDifferentGoogleAccount();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          SnackBarUtil.showError(context, errorMessage);
        }
      }
    });

    return Column(
      children: [
        const SizedBox(height: medium),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
              context,
              iconAssetPath: Assets.Svgs.google,
              onPressed: () {
                print("구글 로그인 버튼 클릭");
                // 수정: socialLoginNotifierProvider 사용
                ref
                    .read(socialLoginNotifierProvider.notifier)
                    .signInWithGoogle();
              },
            ),
            const SizedBox(width: large),
            _buildSocialIcon(
              context,
              iconAssetPath: Assets.Svgs.naver,
              onPressed: () {
                print("네이버 로그인 버튼 클릭");
                // 수정: socialLoginNotifierProvider 사용
                ref
                    .read(socialLoginNotifierProvider.notifier)
                    .signInWithNaver();
              },
            ),
            const SizedBox(width: large),
            _buildSocialIcon(
              context,
              iconAssetPath: Assets.Svgs.kakao,
              onPressed: () {
                print("카카오 로그인 클릭");
                SnackBarUtil.showInfo(context, "카카오 로그인은 현재 지원되지 않습니다.");
              },
            ),
          ],
        ),
        const SizedBox(height: medium),
        CustomButtonLarge(
          text: "아이디/이메일 로그인",
          onPressed: () {
            print("아이디/이메일 로그인 클릭됨");
            Navigator.pushNamed(context, "/account-login");
          },
        ),
        const SizedBox(height: small),
        Center(
          child: CustomLInkGrey(
            text: '아직 아이디가 없으신가요? 회원가입',
            onPressed: () {
              Navigator.pushNamed(context, "/terms");
            },
          ),
        ),
        const SizedBox(height: xSmall),
        Center(
          child: CustomLInkGrey(
            text: '아이디/비밀번호가 생각나지 않으세요? 계정찾기',
            onPressed: () {
              Navigator.pushNamed(context, "/find-account");
            },
          ),
        ),
      ],
    );
  }
}
