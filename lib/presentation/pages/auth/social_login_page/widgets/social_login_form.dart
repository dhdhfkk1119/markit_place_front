import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/size.dart';
import '../../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../../../domain/social_login/social_login_provider.dart';
import '../../../../widgets/custom_button_large.dart';
import '../../../../widgets/custom_link_grey.dart';
import '../../../../widgets/snackbar_util.dart';

class SocialLoginForm extends ConsumerWidget {
  const SocialLoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 위젯이 빌드될 때 Auth 상태 변화를 감지하는 리스너를 설정합니다.
    _listenToAuthState(context, ref);

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
                ref
                    .read(socialLoginNotifierProvider.notifier)
                    .signInWithNaver();
              },
            ),
          ],
        ),
        const SizedBox(height: medium),
        CustomButtonLarge(
          text: "아이디/이메일 로그인",
          onPressed: () {
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

  /// 소셜 로그인 아이콘을 생성합니다.
  /// [size.dart]의 [xxLarge] 상수를 사용하여 아이콘 크기를 일관되게 관리합니다.
  Widget _buildSocialIcon(BuildContext context,
      {required String iconAssetPath, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(xxLarge / 2 + xSmall),
      child: Padding(
        padding: const EdgeInsets.all(xSmall),
        child: SvgPicture.asset(
          iconAssetPath,
          height: xxLarge, // 48.0 대신 상수 사용
          width: xxLarge, // 48.0 대신 상수 사용
        ),
      ),
    );
  }

  /// 인증 상태(AuthState)의 변화를 감지하고 그에 따른 UI 피드백(네비게이션, 다이얼로그)을 처리합니다.
  void _listenToAuthState(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      // 로그인 성공 시 메인 페이지로 이동
      if (next.status == AuthStatus.authenticated &&
          previous?.status != AuthStatus.authenticated) {
        if (next.loginType == LoginType.social) {
          SnackBarUtil.showSuccess(context, "소셜 로그인 성공!");
        }
        Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
      }
      // 에러 발생 시 처리
      else if (next.status == AuthStatus.error &&
          (previous?.status != AuthStatus.error ||
              previous?.errorMessage != next.errorMessage)) {
        final errorMessage = next.errorMessage ?? "소셜 로그인에 실패했습니다.";

        // 특정 에러 메시지(이메일 중복)에 대해 전용 다이얼로그 표시
        if (errorMessage.contains("이미 사용 중인 이메일입니다")) {
          _showEmailInUseDialog(context);
        } else {
          SnackBarUtil.showError(context, errorMessage);
        }
      }
    });
  }

  /// '이미 사용 중인 이메일' 에러가 발생했을 때 표시할 다이얼로그입니다.
  /// 특정 소셜 로그인(예: Google)에 종속되지 않도록 내용을 일반화했습니다.
  void _showEmailInUseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("로그인 실패"),
          content: const Text(
              "선택하신 소셜 계정의 이메일이 이미 다른 방식으로 가입되어 있습니다.\n\n기존 방식으로 로그인하시거나, 다른 소셜 계정을 이용해주세요."),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
