import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/assets.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/domain/members/providers/member_auth_provider.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_medium.dart';
// AppTextFormField import 추가
import 'package:markit_place_front/presentation/widgets/app_text_form_field.dart';

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
      await ref
          .read(authNotifierProvider.notifier)
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

      // "Exception: " 또는 유사한 접두사 제거
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring("Exception: ".length);
      } else if (errorMessage.startsWith("DioException [unknown]: ")) {
        // 만약 Repository가 DioException을 그대로 던진다면 여기서 추가 파싱이 필요할 수 있으나,
        // 현재는 Repository가 메시지를 Exception에 담아 보내주고 있다고 가정합니다.
      }
      // "Error: " 접두사도 필요시 제거할 수 있습니다.
      // else if (errorMessage.startsWith("Error: ")) {
      //   errorMessage = errorMessage.substring("Error: ".length);
      // }

      // 서버가 준 메시지가 "이미 가입된 이메일입니다."인지 직접 확인
      if (errorMessage == "이미 가입된 이메일입니다.") {
        // 특정 메시지일 경우 그대로 사용
      } else {
        // 그 외의 경우, 일반적인 실패 메시지 형태로 가공
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
      final isVerified = await ref
          .read(authNotifierProvider.notifier)
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
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring("Exception: ".length);
      }
      // 인증 실패 관련 특정 메시지 처리 (필요시)
      // if (errorMessage == "인증번호가 일치하지 않습니다.") {
      //   // 특정 메시지 처리
      // } else {
      //   errorMessage = '인증 실패: $errorMessage';
      // }

      // 현재는 모든 인증 실패를 일반적인 형태로 표시
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
                isLoading: _isSendingVerificationEmail,
                onPressed: _isSendingVerificationEmail || currentIsEmailVerified
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
                helperText: '이메일로 전송된 인증번호 6자리를 입력해주세요.',
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
                isLoading: _isConfirmingVerificationCode,
                onPressed:
                    _isConfirmingVerificationCode || currentIsEmailVerified
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
