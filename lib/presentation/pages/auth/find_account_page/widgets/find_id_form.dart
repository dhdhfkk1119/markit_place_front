import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart';
import 'package:markit_place_front/presentation/widgets/custom_link_grey.dart';

import '../../../../../_core/constants/assets.dart'; // 새로운 위젯 임포트

class FindIdForm extends ConsumerStatefulWidget {
  const FindIdForm({super.key});

  @override
  ConsumerState<FindIdForm> createState() => _FindIdFormState();
}

class _FindIdFormState extends ConsumerState<FindIdForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String _maskedId = '';
  bool _isLoadingShowMaskedId = false;
  bool _isLoadingSendEmail = false;
  String _message = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleShowMaskedId() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoadingShowMaskedId = true;
        _message = '';
        _maskedId = '';
      });
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate API call
      _maskedId = "ide***********"; // 샘플 마스킹 아이디
      if (!mounted) return;
      setState(() {
        _isLoadingShowMaskedId = false;
      });
    }
  }

  Future<void> _handleSendFullIdByEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoadingSendEmail = true;
        _message = '';
      });
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      bool success = true; // API 호출 결과에 따라 설정
      if (!mounted) return;
      if (success) {
        _message = '이메일로 아이디 정보가 발송되었습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_message,
                  style: const TextStyle(fontFamily: Fonts.cookieRun))),
        );
      } else {
        _message = '이메일 발송에 실패했습니다. 다시 시도해주세요.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_message,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontFamily: Fonts.cookieRun))),
        );
      }
      setState(() {
        _isLoadingSendEmail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cookieRunPrimaryColorTextStyle = TextStyle(
        fontFamily: Fonts.cookieRun, color: theme.colorScheme.primary);

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
                  ?.copyWith(fontFamily: Fonts.cookieRun),
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
                if (!value.contains('@') || !value.contains('.')) {
                  return '유효한 이메일 형식이 아닙니다.';
                }
                return null;
              },
            ),
            const SizedBox(height: medium),
            if (_message.isNotEmpty &&
                _maskedId.isEmpty &&
                !_isLoadingSendEmail &&
                !_isLoadingShowMaskedId)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: small),
                child: Text(
                  _message,
                  style: TextStyle(
                      fontFamily: Fonts.cookieRun,
                      color:
                          _message.contains("실패") || _message.contains("없습니다")
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface),
                ),
              ),
            if (_maskedId.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: small),
                child: Text(
                  '확인된 아이디: $_maskedId',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold, fontFamily: Fonts.cookieRun),
                ),
              ),
            const SizedBox(height: large),
            if (_maskedId.isEmpty)
              CustomButtonLarge(
                text: '화면에 마스킹된 아이디 보기',
                onPressed: _isLoadingShowMaskedId || _isLoadingSendEmail
                    ? null
                    : () {
                        _handleShowMaskedId();
                      },
              )
            else
              CustomButtonLarge(
                text: '아이디로 로그인하기',
                onPressed: _isLoadingShowMaskedId
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/account-login');
                      },
              ),
            const SizedBox(height: small),
            Center(
              child: CustomLInkGrey(
                // StyledLinkTextButton으로 변경
                text: '이메일로 전체 아이디 전송',
                onPressed: _isLoadingSendEmail || _isLoadingShowMaskedId
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
