import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/presentation/widgets/custom_elevated_button.dart'; // 수정된 위젯 임포트

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
      _maskedId = "ide***********"; // 샘플 마스킹 아이디
      await Future.delayed(const Duration(milliseconds: 500));
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
        // _maskedId = ''; // 이메일 전송 시 마스킹 아이디를 지울지 여부 (UI 흐름에 따라 결정)
      });
      await Future.delayed(const Duration(seconds: 1));
      bool success = true;
      if (success) {
        _message = '[샘플] 이메일로 아이디 정보가 발송되었습니다.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_message)),
          );
        }
      } else {
        _message = '[샘플] 이메일 발송에 실패했습니다. 다시 시도해주세요.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_message,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error))),
          );
        }
      }
      setState(() {
        _isLoadingSendEmail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 로컬 ButtonStyle과 TextStyle 정의 제거
    // final ButtonStyle loginPageButtonStyle = ... (제거)
    // const TextStyle buttonTextStyle = ... (제거)

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
                  ?.copyWith(fontFamily: "CookieRun"),
            ),
            const SizedBox(height: medium),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: '이메일 입력',
              ),
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
                      fontFamily: "CookieRun",
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
                      fontWeight: FontWeight.bold, fontFamily: "CookieRun"),
                ),
              ),
            const SizedBox(height: large),
            if (_maskedId.isEmpty)
              CustomElevatedButton(
                text: '화면에 마스킹된 아이디 보기',
                onPressed: _isLoadingSendEmail ? null : _handleShowMaskedId,
                isLoading: _isLoadingShowMaskedId,
              )
            else
              CustomElevatedButton(
                text: '아이디로 로그인하기',
                onPressed: () {
                  Navigator.pushNamed(context, '/account-login');
                },
                isLoading: _isLoadingShowMaskedId, // 이 버튼은 자체 로딩 상태가 거의 필요 없지만,
                // _isLoadingShowMaskedId를 사용해 이전 버튼의 로딩 상태를 공유할 수 있음
                // 또는 별도 로딩 상태 변수 사용 가능
              ),
            const SizedBox(height: small),
            CustomElevatedButton(
              text: '이메일로 전체 아이디 전송',
              onPressed:
                  _isLoadingShowMaskedId ? null : _handleSendFullIdByEmail,
              isLoading: _isLoadingSendEmail,
            ),
          ],
        ),
      ),
    );
  }
}
