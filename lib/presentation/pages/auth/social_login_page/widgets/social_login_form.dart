import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/size.dart';
import '../../../../../../domain/members/providers/member_auth_provider.dart';
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
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated &&
          previous?.status != AuthStatus.authenticated) {
        if (next.loginType == LoginType.social) {
          String successMessage = "소셜 로그인 성공!";
          // TODO: 향후 확장 시, next.user.loginId를 분석하여 특정 소셜 서비스(구글, 네이버)별 메시지 차별화 가능
          // 예: if (next.user?.loginId.startsWith("google_") ?? false) successMessage = "구글 로그인 성공!";
          // else if (next.user?.loginId.startsWith("naver_") ?? false) successMessage = "네이버 로그인 성공!";
          SnackBarUtil.showSuccess(context, successMessage);
        }
        Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
      }
      // ==== 에러 상태 처리 로직 ====
      else if (next.status == AuthStatus.error &&
          (previous?.status != AuthStatus.error ||
              previous?.errorMessage != next.errorMessage)) {
        // 에러 메시지가 변경되었거나 처음 에러 발생 시에만 처리
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
                      // 선택 사항: AuthNotifier의 오류 상태 초기화
                      // ref.read(authNotifierProvider.notifier).clearError(); // clearError 메소드 구현 필요
                    },
                  ),
                  TextButton(
                    // "다른 Google 계정 선택" 버튼 추가
                    child: const Text('다른 Google 계정 선택'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      ref
                          .read(authNotifierProvider.notifier)
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
        // 소셜 로그인 아이콘 (구글, 네이버, 카카오)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
              context,
              iconAssetPath: Assets.Svgs.google,
              onPressed: () {
                print("구글 로그인 버튼 클릭");
                ref.read(authNotifierProvider.notifier).signInWithGoogle();
              },
            ),
            const SizedBox(width: large),
            _buildSocialIcon(
              context,
              iconAssetPath: Assets.Svgs.naver,
              onPressed: () {
                print("네이버 로그인 버튼 클릭");
                ref.read(authNotifierProvider.notifier).signInWithNaver();
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
        // 아이디/이메일(계정) 로그인 버튼
        CustomButtonLarge(
          text: "아이디/이메일 로그인",
          onPressed: () {
            print("아이디/이메일 로그인 클릭됨");
            Navigator.pushNamed(context, "/account-login");
          },
        ),
        const SizedBox(height: small),
        // 회원가입 링크
        Center(
          child: CustomLInkGrey(
            text: '아직 아이디가 없으신가요? 회원가입',
            onPressed: () {
              Navigator.pushNamed(context, "/terms");
            },
          ),
        ),
        const SizedBox(height: xSmall),
        // 계정찾기 링크
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
