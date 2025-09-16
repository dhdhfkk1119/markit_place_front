import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added for ConsumerWidget
import 'package:flutter_svg/svg.dart';
import 'package:markit_place_front/_core/constants/assets.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart';
import 'package:markit_place_front/presentation/widgets/custom_link_grey.dart';
// Import AuthNotifier
import 'package:markit_place_front/domain/members/providers/member_auth_provider.dart';
// UserRepository import is no longer needed
// import 'package:markit_place_front/domain/repositories/auth_repository/user_repository.dart';

// Changed from StatelessWidget to ConsumerWidget
class SocialLoginForm extends ConsumerWidget {
  const SocialLoginForm({super.key});

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
  // Added WidgetRef ref
  Widget build(BuildContext context, WidgetRef ref) {
    // It's good practice to listen to AuthState changes for UI feedback (e.g., navigation, SnackBar)
    // Similar to AccountLoginForm, you might want to add:
    // ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    //   if (next.status == AuthStatus.authenticated) {
    //     SnackBarUtil.showSuccess(context, "소셜 로그인 성공!");
    //     Navigator.pushReplacementNamed(context, "/main");
    //   } else if (next.status == AuthStatus.error) {
    //     SnackBarUtil.showError(context, next.errorMessage ?? "소셜 로그인에 실패했습니다.");
    //   }
    // });

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
                // TODO: 구글 로그인 로직 구현 (AuthNotifier 사용)
                print("구글 로그인 클릭");
                // 예시: ref.read(authNotifierProvider.notifier).signInWithGoogle();
                // Navigator.pushNamed(context, "product/list"); // 성공 시 AuthState 리스너가 처리
              },
            ),
            const SizedBox(width: large),
            _buildSocialIcon(
              context,
              iconAssetPath: Assets.Svgs.naver,
              onPressed: () {
                print("네이버 로그인 클릭");
                // Changed to use AuthNotifier
                ref.read(authNotifierProvider.notifier).signInWithNaver();
              },
            ),
            const SizedBox(width: large),
            _buildSocialIcon(
              context,
              iconAssetPath: Assets.Svgs.kakao,
              onPressed: () {
                // TODO: 카카오 로그인 로직 구현 (AuthNotifier 사용)
                print("카카오 로그인 클릭");
                // 예시: ref.read(authNotifierProvider.notifier).signInWithKakao();
                // Navigator.pushNamed(context, "product/list"); // 성공 시 AuthState 리스너가 처리
              },
            ),
          ],
        ),
        const SizedBox(height: medium),
        CustomButtonLarge(
          text: "일반이메일 로그인",
          onPressed: () {
            print("일반이메일 로그인 클릭됨");
            Navigator.pushNamed(context, "/account-login");
          },
        ),
        const SizedBox(height: small),
        Center(
          child: CustomLInkGrey(
            text: '아이디로 로그인하기',
            onPressed: () {
              Navigator.pushNamed(context, "/account-login");
            },
          ),
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
