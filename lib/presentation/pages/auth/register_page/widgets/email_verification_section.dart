import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/assets.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../_core/constants/size.dart';
import '../../../../../domain/members/providers/email_verification_provider.dart';
import '../../../../widgets/custom_button_medium.dart';
import '../../../../widgets/app_text_form_field.dart';

class EmailVerificationSection extends ConsumerStatefulWidget {
  final TextEditingController emailController;
  final TextEditingController verificationCodeController;
  final FocusNode emailFocusNode;
  final FocusNode verificationCodeFocusNode;
  final bool isEmailAlreadyVerified;
  final List<String> suggestedDomains;
  final Function(String) onDomainSuggestionTap;

  const EmailVerificationSection({
    Key? key,
    required this.emailController,
    required this.verificationCodeController,
    required this.emailFocusNode,
    required this.verificationCodeFocusNode,
    required this.isEmailAlreadyVerified,
    required this.suggestedDomains,
    required this.onDomainSuggestionTap,
  }) : super(key: key);

  @override
  ConsumerState<EmailVerificationSection> createState() =>
      _EmailVerificationSectionState();
}

class _EmailVerificationSectionState
    extends ConsumerState<EmailVerificationSection> {
  Future<void> _handleSendVerificationEmail() async {
    final email = widget.emailController.text;
    final emailRegExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");

    if (email.isEmpty || !emailRegExp.hasMatch(email)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('유효한 이메일 주소를 입력해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      return;
    }

    await ref
        .read(emailVerificationNotifierProvider.notifier)
        .requestEmailVerification(email);
  }

  Future<void> _handleConfirmVerificationCode() async {
    final email = widget.emailController.text;
    final code = widget.verificationCodeController.text;

    if (email.isEmpty || code.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('이메일과 인증번호를 모두 입력해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      return;
    }
    if (code.length != 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('인증번호 6자리를 입력해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      return;
    }

    await ref
        .read(emailVerificationNotifierProvider.notifier)
        .confirmEmailVerification(email, code);
  }

  @override
  Widget build(BuildContext context) {
    final emailVerificationState = ref.watch(emailVerificationNotifierProvider);
    final cookieRunBlackTextStyle =
        TextStyle(fontFamily: Assets.Fonts.cookieRun, color: Colors.black87);
    final currentIsEmailVerified = widget.isEmailAlreadyVerified ||
        emailVerificationState.status == EmailVerificationStatus.verified;

    final successTextStyle = TextStyle(
      fontFamily: Assets.Fonts.cookieRun,
      color: Colors.green, // 초록색
    );

    ref.listen<EmailVerificationState>(emailVerificationNotifierProvider,
        (previous, next) {
      if (previous?.status != EmailVerificationStatus.codeSent &&
          next.status == EmailVerificationStatus.codeSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('인증번호가 발송되었습니다. 이메일을 확인해주세요.',
                  style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
        );
      } else if (previous?.status != EmailVerificationStatus.verified &&
          next.status == EmailVerificationStatus.verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('이메일 인증이 완료되었습니다.',
                  style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
        );
        widget.verificationCodeController.clear();
        FocusScope.of(context).unfocus();
      } else if (next.status == EmailVerificationStatus.error &&
          next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        if (next.errorMessage == '인증번호가 일치하지 않습니다.') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(next.errorMessage!,
                    style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
          );
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomWidget.buildTitle("이메일 인증하기"),
        const SizedBox(height: small),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextFormField(
                controller: widget.emailController,
                focusNode: widget.emailFocusNode,
                labelText: '이메일 주소',
                keyboardType: TextInputType.emailAddress,
                helperText: '예: example@markit.com',
                readOnly: currentIsEmailVerified,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일 주소를 입력해주세요.';
                  }
                  final emailRegex = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
                  if (!emailRegex.hasMatch(value)) {
                    return '유효한 이메일 형식이 아닙니다.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: small, top: small, right: xSmall),
              child: CustomButtonMedium(
                text: '인증번호 전송',
                isLoading: emailVerificationState.status ==
                    EmailVerificationStatus.loading,
                onPressed: currentIsEmailVerified
                    ? null
                    : _handleSendVerificationEmail,
              ),
            ),
          ],
        ),
        if (emailVerificationState.status == EmailVerificationStatus.error &&
            emailVerificationState.errorMessage != null &&
            emailVerificationState.errorMessage != '인증번호가 일치하지 않습니다.')
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 12.0),
            child: Text(
              emailVerificationState.errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.0,
                fontFamily: Assets.Fonts.cookieRun,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: xSmall),
          child: Wrap(
            spacing: small,
            runSpacing: xSmall,
            children: widget.suggestedDomains.map((domain) {
              return OutlinedButton(
                onPressed: currentIsEmailVerified
                    ? null
                    : () => widget.onDomainSuggestionTap(domain),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: small, vertical: xSmall),
                  side: BorderSide(color: Colors.grey.shade400, width: 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(small),
                  ),
                ),
                child: Text(domain, style: cookieRunBlackTextStyle),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: medium),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextFormField(
                controller: widget.verificationCodeController,
                focusNode: widget.verificationCodeFocusNode,
                labelText: '인증번호',
                helperText: currentIsEmailVerified
                    ? '인증이 완료됐습니다.'
                    : '이메일로 전송된 인증번호 6자리를 입력해주세요.',
                helperStyle: currentIsEmailVerified ? successTextStyle : null,
                keyboardType: TextInputType.number,
                readOnly: currentIsEmailVerified,
                validator: (value) {
                  if (!currentIsEmailVerified &&
                      (value == null || value.isEmpty)) {
                    return '인증번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: small, top: small, right: xSmall),
              child: CustomButtonMedium(
                text: currentIsEmailVerified ? '인증완료' : '인증확인',
                isLoading: emailVerificationState.status ==
                    EmailVerificationStatus.loading,
                onPressed: currentIsEmailVerified
                    ? null
                    : _handleConfirmVerificationCode,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
