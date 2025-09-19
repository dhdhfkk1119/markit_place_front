import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/assets.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../_core/constants/size.dart';
// import '../../../../../domain/members/providers/member_auth_provider.dart'; // EmailVerificationNotifier를 사용하므로 주석 처리 또는 삭제
import '../../../../../domain/members/providers/email_verification_provider.dart'; // 수정된 부분
import '../../../../widgets/custom_button_medium.dart';
// AppTextFormField import 추가
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
  bool _isSendingVerificationEmail = false;
  bool _isConfirmingVerificationCode = false;

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

    setState(() {
      _isSendingVerificationEmail = true;
    });

    try {
      // 수정된 부분: emailVerificationNotifierProvider 사용
      await ref
          .read(emailVerificationNotifierProvider.notifier)
          .requestEmailVerification(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('인증번호가 발송되었습니다. 이메일을 확인해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString();

      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring("Exception: ".length);
      } else if (errorMessage.startsWith("DioException [unknown]: ")) {
        // Error handling as before
      }

      if (errorMessage == "이미 가입된 이메일입니다.") {
        // Specific message handling
      } else {
        errorMessage = '인증번호 발송 실패: $errorMessage';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(errorMessage,
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingVerificationEmail = false;
        });
      }
    }
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

    setState(() {
      _isConfirmingVerificationCode = true;
    });

    try {
      // 수정된 부분: emailVerificationNotifierProvider 사용
      final isVerified = await ref
          .read(emailVerificationNotifierProvider.notifier)
          .confirmEmailVerification(email, code);
      if (!mounted) return;

      if (isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('이메일 인증이 완료되었습니다.',
                  style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
        );
        widget.verificationCodeController.clear();
        FocusScope.of(context).unfocus();
        // 여기에 추가: 인증 성공 상태를 상위 위젯(RegisterForm)에 알리거나,
        // EmailVerificationState의 isVerifiedForCurrentSession를 직접 사용하도록 RegisterForm을 수정해야 할 수 있습니다.
        // 예: ref.read(emailVerificationNotifierProvider.notifier).consumeVerificationSuccess(); (만약 상태 소비 로직이 있다면)
      }
      // 인증 실패 시 (isVerified == false) EmailVerificationNotifier 내부에서 상태가 error로 설정되고
      // errorMessage가 채워지므로, 여기서 별도 SnackBar 처리를 하지 않아도 Notifier의 상태 변화를 통해 UI에 반영될 수 있습니다.
      // 만약 여기서 직접 SnackBar를 띄우고 싶다면, EmailVerificationNotifier의 confirmEmailVerification이
      // false를 반환했을 때의 로직을 추가합니다.
      // else {
      //   if (!mounted) return;
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //         content: Text(ref.read(emailVerificationNotifierProvider).errorMessage ?? '인증번호가 일치하지 않습니다.',
      //             style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      //   );
      // }
    } catch (e) {
      // Notifier에서 발생한 예외 (네트워크 오류 등)는 여기서 catch 가능
      if (!mounted) return;
      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring("Exception: ".length);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('인증 실패: $errorMessage',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isConfirmingVerificationCode = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cookieRunBlackTextStyle =
        TextStyle(fontFamily: Assets.Fonts.cookieRun, color: Colors.black87);
    final currentIsEmailVerified = widget.isEmailAlreadyVerified;
    // final emailVerificationState = ref.watch(emailVerificationNotifierProvider); // 상태를 직접 watch 할 수도 있음

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
                readOnly:
                    currentIsEmailVerified, // || emailVerificationState.status == EmailVerificationStatus.verified,
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
                isLoading: _isSendingVerificationEmail,
                onPressed: _isSendingVerificationEmail ||
                        currentIsEmailVerified // || emailVerificationState.status == EmailVerificationStatus.verified
                    ? null
                    : _handleSendVerificationEmail,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: xSmall),
          child: Wrap(
            spacing: small,
            runSpacing: xSmall,
            children: widget.suggestedDomains.map((domain) {
              return OutlinedButton(
                onPressed:
                    currentIsEmailVerified // || emailVerificationState.status == EmailVerificationStatus.verified
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
                helperText: '이메일로 전송된 인증번호 6자리를 입력해주세요.',
                keyboardType: TextInputType.number,
                readOnly:
                    currentIsEmailVerified, // || emailVerificationState.status == EmailVerificationStatus.verified,
                validator: (value) {
                  // if (emailVerificationState.status != EmailVerificationStatus.verified && !currentIsEmailVerified && (value == null || value.isEmpty)) {
                  if (!currentIsEmailVerified &&
                      (value == null || value.isEmpty)) {
                    // 임시로 기존 로직 유지
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
                text: currentIsEmailVerified
                    ? '인증완료'
                    : '인증확인', // emailVerificationState.status == EmailVerificationStatus.verified ? '인증완료' : '인증확인',
                isLoading: _isConfirmingVerificationCode,
                onPressed: _isConfirmingVerificationCode ||
                        currentIsEmailVerified // || emailVerificationState.status == EmailVerificationStatus.verified
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
