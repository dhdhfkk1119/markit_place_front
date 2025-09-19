import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/size.dart';
import '../../../../../domain/members/providers/find_account_provider.dart';
import '../../../../widgets/custom_button_large.dart';
import '../../../../widgets/custom_link_grey.dart';
import '../../../../../_core/constants/assets.dart';

class FindIdForm extends ConsumerStatefulWidget {
  const FindIdForm({super.key});

  @override
  ConsumerState<FindIdForm> createState() => _FindIdFormState();
}

class _FindIdFormState extends ConsumerState<FindIdForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    // 위젯이 화면에서 사라질 때 notifier의 상태를 초기화 할 수 있습니다. (선택 사항)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     ref.read(findIdNotifierProvider.notifier).resetState();
    //   }
    // });
    super.dispose();
  }

  // --- Button Handlers ---
  void _handleShowMaskedId() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(findIdNotifierProvider.notifier)
          .fetchMaskedId(_emailController.text);
    }
  }

  void _handleSendFullIdByEmail() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(findIdNotifierProvider.notifier)
          .sendLoginIdToEmail(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cookieRunTextStyle = TextStyle(fontFamily: Assets.Fonts.cookieRun);
    final cookieRunPrimaryColorTextStyle = TextStyle(
        fontFamily: Assets.Fonts.cookieRun, color: theme.colorScheme.primary);

    final findIdState = ref.watch(findIdNotifierProvider);

    ref.listen<FindIdState>(findIdNotifierProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.errorMessage!,
                  style: cookieRunTextStyle.copyWith(
                      color: theme.colorScheme.error)),
              duration: const Duration(seconds: 3)),
        );
        // 메시지 표시 후 상태에서 메시지 제거
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted)
            ref.read(findIdNotifierProvider.notifier).clearMessages();
        });
      }
      if (next.infoMessage != null && next.infoMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.infoMessage!, style: cookieRunTextStyle),
              duration: const Duration(seconds: 3)),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted)
            ref.read(findIdNotifierProvider.notifier).clearMessages();
        });
      }
    });

    return Padding(
      padding: const EdgeInsets.all(medium),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: medium),
            Text(
              '등록된 이메일 주소를 입력해주세요.',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontFamily: Assets.Fonts.cookieRun),
            ),
            const SizedBox(height: medium),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: '이메일 입력',
              ),
              style: cookieRunPrimaryColorTextStyle,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이메일 주소를 입력해주세요.';
                }
                final emailRegExp = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
                if (!emailRegExp.hasMatch(value)) {
                  return '유효한 이메일 형식이 아닙니다.';
                }
                return null;
              },
            ),
            const SizedBox(height: medium),

            // 마스킹된 아이디 표시
            if (findIdState.maskedId != null &&
                findIdState.maskedId!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: small),
                child: Text(
                  '확인된 아이디: ${findIdState.maskedId}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: Assets.Fonts.cookieRun),
                ),
              ),

            const SizedBox(height: large),

            // 조건에 따라 버튼 표시
            if (findIdState.maskedId == null || findIdState.maskedId!.isEmpty)
              CustomButtonLarge(
                text: '화면에 마스킹된 아이디 보기',
                isLoading: findIdState.isLoadingMaskedId,
                onPressed: findIdState.isLoadingMaskedId ||
                        findIdState.isLoadingSendEmail
                    ? null
                    : _handleShowMaskedId,
              )
            else
              CustomButtonLarge(
                text: '아이디로 로그인하기',
                isLoading: false, // 이 버튼 자체는 로딩 상태가 직접 연관되지 않을 수 있음
                onPressed: () {
                  // 로그인 페이지로 이동하기 전에 상태 초기화 (선택 사항)
                  // ref.read(findIdNotifierProvider.notifier).resetState();
                  Navigator.pushNamed(context, '/account-login');
                },
              ),
            const SizedBox(height: small),
            Center(
              child: CustomLInkGrey(
                text: '이메일로 전체 아이디 전송',
                onPressed: findIdState.isLoadingSendEmail ||
                        findIdState.isLoadingMaskedId
                    ? null
                    : _handleSendFullIdByEmail,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
