import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/assets.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../_core/constants/size.dart';
import '../../../../../domain/members/models/member.dart';
import '../../../../../domain/members/providers/email_verification_provider.dart';
import '../../../../../domain/members/providers/register_provider.dart';
import '../../../../widgets/custom_button_large.dart';
import 'email_verification_section.dart';
import 'id_verification_section.dart';
import 'password_verification_section.dart';

class RegisterForm extends ConsumerStatefulWidget {
  final List<int> agreedTermIds;

  const RegisterForm({super.key, required this.agreedTermIds});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController(text: 'user3');
  final _passwordController = TextEditingController(text: 'user1234');
  final _passwordConfirmController = TextEditingController(text: 'user1234');
  final _emailController = TextEditingController(text: 'user3@gmail.com');
  final _verificationCodeController = TextEditingController();

  final _idFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _verificationCodeFocusNode = FocusNode();

  final _scrollController = ScrollController();

  late final List<TextEditingController> _allControllers;
  late final List<FocusNode> _allFocusNodes;

  final List<String> _suggestedDomains = [
    'gmail.com',
    'naver.com',
    'kakao.com',
    'hanmail.net',
    'daum.net',
    'nate.com',
  ];

  @override
  void initState() {
    super.initState();
    _allControllers = [
      _idController,
      _passwordController,
      _passwordConfirmController,
      _emailController,
      _verificationCodeController,
    ];
    _allFocusNodes = [
      _idFocusNode,
      _passwordFocusNode,
      _passwordConfirmFocusNode,
      _emailFocusNode,
      _verificationCodeFocusNode,
    ];
    for (final node in _allFocusNodes) {
      node.addListener(() => _ensureVisible(node));
    }
    print("[RegisterForm initState] agreedTermIds: ${widget.agreedTermIds}");
  }

  @override
  void dispose() {
    for (final controller in _allControllers) {
      controller.dispose();
    }
    for (final node in _allFocusNodes) {
      node.removeListener(() => _ensureVisible(node));
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureVisible(FocusNode node) {
    if (node.hasFocus && mounted && node.context != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && node.context != null && node.hasFocus) {
          Scrollable.ensureVisible(
            node.context!,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      });
    }
  }

  void _onDomainSuggestionTap(String domain) {
    String currentText = _emailController.text;
    final atSignIndex = currentText.indexOf('@');
    if (atSignIndex != -1) {
      currentText = currentText.substring(0, atSignIndex);
    }
    _emailController.text = '$currentText@$domain';
    _emailController.selection = TextSelection.fromPosition(
      TextPosition(offset: _emailController.text.length),
    );
    _emailFocusNode.requestFocus();
  }

  Future<void> _checkIdAvailability() async {
    final idValue = _idController.text;
    if (idValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('아이디를 입력해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      return;
    }
    if (idValue.length < 4 || idValue.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('아이디는 4자 이상 20자 이하로 입력해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      return;
    }
    if (idValue.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('아이디에 공백을 포함할 수 없습니다.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      return;
    }
    await ref
        .read(registerNotifierProvider.notifier)
        .checkIdAvailability(idValue);
  }

  void _onRegisterButtonPressed() {
    final registerNotifier = ref.read(registerNotifierProvider.notifier);
    final currentRegisterState = ref.read(registerNotifierProvider);
    final emailVerificationState = ref.read(emailVerificationNotifierProvider);

    if (currentRegisterState.status == RegisterStatus.loading) {
      return;
    }

    if (!(currentRegisterState.isIdChecked == true &&
        currentRegisterState.status == RegisterStatus.idAvailable)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('아이디 중복 확인을 해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      _idFocusNode.requestFocus();
      return;
    }

    if (!emailVerificationState.isVerifiedForCurrentSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('이메일 인증을 먼저 완료해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      _emailFocusNode.requestFocus();
      return;
    }

    if (widget.agreedTermIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('약관 동의 정보가 올바르지 않습니다. 다시 시도해주세요.',
              style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final memberToRegister = Member.forRegistration(
        loginId: _idController.text,
        password: _passwordController.text,
        email: _emailController.text,
        agreedTermIds: widget.agreedTermIds,
        isEmailVerified: emailVerificationState.isVerifiedForCurrentSession,
      );
      registerNotifier.register(memberToRegister);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('입력 내용을 다시 확인해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerNotifierProvider);
    final emailVerificationState = ref.watch(emailVerificationNotifierProvider);
    final bool isEmailVerified =
        emailVerificationState.isVerifiedForCurrentSession;

    final cookieRunTextStyle = TextStyle(fontFamily: Assets.Fonts.cookieRun);

    ref.listen<RegisterState>(registerNotifierProvider, (previous, next) {
      if (previous?.status != RegisterStatus.success &&
          next.status == RegisterStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.successMessage ?? "회원가입 성공! 로그인해주세요.",
                  style: cookieRunTextStyle)),
        );
        ref.read(registerNotifierProvider.notifier).consumeMessages();

        ref
            .read(emailVerificationNotifierProvider.notifier)
            .resetEmailVerificationState();

        Navigator.pushNamedAndRemoveUntil(
            context, "/social-login", (route) => false);
      } else if (next.status == RegisterStatus.error && !next.isIdChecked!) {
        if (next.errorMessage != null &&
            next.errorMessage!.isNotEmpty &&
            (previous?.errorMessage != next.errorMessage ||
                previous?.status != RegisterStatus.error)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("회원가입 오류: ${next.errorMessage!}",
                    style: cookieRunTextStyle)),
          );
          ref.read(registerNotifierProvider.notifier).consumeMessages();
        }
      }
    });

    return SingleChildScrollView(
      controller: _scrollController,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.buildTitle("아이디/비밀번호 입력하기"),
              const SizedBox(height: small),
              IdVerificationSection(
                idController: _idController,
                idFocusNode: _idFocusNode,
                onCheckIdAvailability: _checkIdAvailability,
              ),
              const SizedBox(height: small),
              PasswordVerificationSection(
                passwordController: _passwordController,
                passwordConfirmController: _passwordConfirmController,
                passwordFocusNode: _passwordFocusNode,
                passwordConfirmFocusNode: _passwordConfirmFocusNode,
              ),
              const SizedBox(height: medium),
              EmailVerificationSection(
                emailController: _emailController,
                verificationCodeController: _verificationCodeController,
                emailFocusNode: _emailFocusNode,
                verificationCodeFocusNode: _verificationCodeFocusNode,
                isEmailAlreadyVerified: isEmailVerified,
                suggestedDomains: _suggestedDomains,
                onDomainSuggestionTap: _onDomainSuggestionTap,
              ),
              const SizedBox(height: medium),
              CustomButtonLarge(
                text: '가입하기',
                isLoading: registerState.status == RegisterStatus.loading,
                onPressed: _onRegisterButtonPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
