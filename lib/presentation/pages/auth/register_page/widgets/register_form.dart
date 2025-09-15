import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/domain/members/models/member.dart';
import 'package:markit_place_front/domain/members/providers/member_auth_provider.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_medium.dart';

import '../../../../../_core/constants/assets.dart';
// 새로 추가된 EmailVerificationSection import
import './email_verification_section.dart';
// AppTextFormField import 추가
import 'package:markit_place_front/presentation/widgets/app_text_form_field.dart';

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
  final _verificationCodeController = TextEditingController(text: 'user3');

  final _idFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _verificationCodeFocusNode = FocusNode();

  final _scrollController = ScrollController();

  late final List<TextEditingController> _allControllers;
  late final List<FocusNode> _allFocusNodes;

  // 아이디 중복 확인 관련 상태 변수
  bool _isCheckingId = false;
  String _idCheckMessage = '';
  bool _isIdValidAndChecked = false; // 아이디가 유효하고 중복확인 완료(사용 가능) 상태
  Color _idCheckMessageColor = Colors.grey; // 아이디 확인 메시지 색상

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
    // 아이디 컨트롤러 리스너 추가: 아이디 변경 시 중복확인 상태 초기화
    _idController.addListener(() {
      if (_isIdValidAndChecked || _idCheckMessage.isNotEmpty) {
        setState(() {
          _isIdValidAndChecked = false;
          _idCheckMessage = '';
          _idCheckMessageColor = Colors.grey;
        });
      }
    });
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

  // _buildTextFormField 메소드를 AppTextFormField를 사용하도록 수정
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required FormFieldValidator<String> validator,
    FocusNode? focusNode,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? helperText,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    // --- AppTextFormField 사용으로 변경 ---
    return AppTextFormField(
      controller: controller,
      labelText: labelText,
      validator: validator,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      helperText: helperText,
      suffixIcon: suffixIcon,
      readOnly: readOnly,
    );
  }

  // _onDomainSuggestionTap은 EmailVerificationSection에 콜백으로 전달하기 위해 유지
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

  // 아이디 중복확인 버튼 클릭 시 실행될 로직
  Future<void> _checkIdAvailability() async {
    // 아이디 유효성 검사 (Form의 validator와 별개로 버튼 클릭 시에도 필요)
    final idValue = _idController.text;
    if (idValue.isEmpty) {
      setState(() {
        _idCheckMessage = '아이디를 입력해주세요.';
        _idCheckMessageColor = Colors.red;
        _isIdValidAndChecked = false;
      });
      return;
    }
    if (idValue.length < 4 || idValue.length > 20) {
      setState(() {
        _idCheckMessage = '아이디는 4자 이상 20자 이하로 입력해주세요.';
        _idCheckMessageColor = Colors.red;
        _isIdValidAndChecked = false;
      });
      return;
    }
    if (idValue.contains(' ')) {
      setState(() {
        _idCheckMessage = '아이디에 공백을 포함할 수 없습니다.';
        _idCheckMessageColor = Colors.red;
        _isIdValidAndChecked = false;
      });
      return;
    }

    setState(() {
      _isCheckingId = true;
      _idCheckMessage = '확인 중...';
      _idCheckMessageColor = Colors.grey;
    });

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      // 서버 응답: true (사용 가능 - 존재하지 않음), false (사용 불가 - 이미 존재함)
      final bool isAvailable = await authNotifier.checkIdAvailability(idValue);

      if (isAvailable) {
        // 서버가 true (사용 가능)를 반환하면 이 블록 실행
        setState(() {
          _idCheckMessage = '사용 가능한 아이디입니다.';
          _idCheckMessageColor = Colors.green;
          _isIdValidAndChecked = true;
        });
      } else {
        // 서버가 false (사용 불가)를 반환하면 이 블록 실행
        setState(() {
          _idCheckMessage = '이미 사용 중인 아이디입니다.';
          _idCheckMessageColor = Colors.red;
          _isIdValidAndChecked = false;
        });
      }
    } catch (e) {
      setState(() {
        _idCheckMessage =
            '오류: ${e.toString().split(': ').last}'; // Exception 메시지만 표시
        _idCheckMessageColor = Colors.red;
        _isIdValidAndChecked = false;
      });
    } finally {
      setState(() {
        _isCheckingId = false;
      });
    }
  }

  void _onRegisterButtonPressed() {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final currentAuthState = ref.read(authNotifierProvider);

    if (currentAuthState.status == AuthStatus.loading) {
      return;
    }

    // 1. 아이디 중복확인 및 사용 가능 상태 확인
    if (!_isIdValidAndChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('아이디 중복 확인을 해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      _idFocusNode.requestFocus(); // 아이디 필드로 포커스 이동
      return;
    }

    // 2. 이메일 인증 상태 확인 (기존 로직)
    if (!currentAuthState.isEmailVerifiedForRegistration) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('이메일 인증을 먼저 완료해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      // 이메일 또는 인증코드 필드로 포커스 이동 (필요시)
      // _emailFocusNode.requestFocus(); or _verificationCodeFocusNode.requestFocus();
      return;
    }

    // 3. 약관 동의 정보 확인 (기존 로직)
    if (widget.agreedTermIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('약관 동의 정보가 올바르지 않습니다. 다시 시도해주세요.',
              style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
        ),
      );
      return;
    }

    // 4. 폼 유효성 검사 및 회원가입 진행 (기존 로직)
    if (_formKey.currentState!.validate()) {
      final memberToRegister = Member.forRegistration(
        loginId: _idController.text,
        password: _passwordController.text,
        email: _emailController.text,
        agreedTermIds: widget.agreedTermIds,
        isEmailVerified: currentAuthState.isEmailVerifiedForRegistration,
      );
      authNotifier.register(memberToRegister);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final bool isEmailVerified = authState.isEmailVerifiedForRegistration;
    final cookieRunTextStyle = TextStyle(fontFamily: Assets.Fonts.cookieRun);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error &&
          next.errorMessage != null &&
          previous?.status != AuthStatus.error) {
        // 회원가입 실패 시 ID 중복확인 상태는 유지 (이미 다른 오류일 수 있으므로)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.errorMessage!, style: cookieRunTextStyle)),
        );
      } else if (next.status == AuthStatus.unauthenticated &&
          next.errorMessage != null &&
          next.errorMessage == "회원가입 성공! 로그인해주세요.") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.errorMessage!, style: cookieRunTextStyle)),
        );
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        ref
            .read(authNotifierProvider.notifier)
            .clearRegistrationSuccessMessage();
        ref.read(authNotifierProvider.notifier).resetEmailVerificationState();
        // 회원가입 성공 시 아이디 중복확인 상태 초기화도 고려할 수 있음 (선택적)
        // setState(() {
        //   _isIdValidAndChecked = false;
        //   _idCheckMessage = '';
        //   _idCheckMessageColor = Colors.grey;
        // });
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _idController,
                      focusNode: _idFocusNode,
                      labelText: '아이디',
                      // helperText는 _idCheckMessage로 대체 또는 병행 표시 가능
                      // helperText: '아이디는 4자 이상 20자 이하로 입력해주세요.',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '아이디를 입력해주세요.';
                        }
                        if (value.length < 4 || value.length > 20) {
                          return '아이디는 4자 이상 20자 이하로 입력해주세요.';
                        }
                        if (value.contains(' ')) return '아이디에 공백을 포함할 수 없습니다.';
                        // _isIdValidAndChecked 상태는 버튼 클릭으로만 변경되므로 validator에서 직접 사용은 부적절
                        return null;
                      },
                      readOnly: _isCheckingId, // 중복 확인 중에는 수정 불가
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: small, top: small, right: xSmall),
                    child: CustomButtonMedium(
                      text: '중복확인',
                      isLoading: _isCheckingId, // 로딩 상태 바인딩
                      onPressed: _isCheckingId
                          ? null
                          : _checkIdAvailability, // 중복확인 함수 연결
                    ),
                  ),
                ],
              ),
              // 아이디 중복 확인 메시지 표시
              if (_idCheckMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                      top: 4.0, left: 12.0), // AppTextFormField 내부 패딩과 유사하게 조정
                  child: Text(
                    _idCheckMessage,
                    style: TextStyle(
                      fontFamily: Assets.Fonts.cookieRun,
                      color: _idCheckMessageColor,
                      fontSize:
                          12.0, // FormField helperText/errorText 기본값과 유사하게
                    ),
                  ),
                ),
              const SizedBox(height: medium),
              _buildTextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                labelText: '비밀번호',
                obscureText: true,
                helperText: '비밀번호는 8자 이상 20자 이하로 입력해주세요.',
                validator: (value) {
                  if (value == null || value.isEmpty) return '비밀번호를 입력해주세요.';
                  if (value.length < 8 || value.length > 20) {
                    return '비밀번호는 8자 이상 20자 이하이어야 합니다.';
                  }
                  return null;
                },
                readOnly: false,
              ),
              const SizedBox(height: medium),
              _buildTextFormField(
                controller: _passwordConfirmController,
                focusNode: _passwordConfirmFocusNode,
                labelText: '비밀번호 확인',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 다시 한번 입력해주세요.';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
                readOnly: false,
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
              const SizedBox(height: xLarge),
              CustomButtonLarge(
                text: authState.status == AuthStatus.loading &&
                        !_isCheckingId // _isCheckingId가 아닐 때만 '가입 처리 중'
                    ? '가입 처리 중...'
                    : '가입하기',
                // 가입하기 버튼 활성화 조건:
                // 1. AuthProvider가 로딩중이 아니고 (일반적인 가입 로딩)
                // 2. 아이디 중복확인 로딩중이 아니고
                // 3. 약관 동의했고
                // 4. 아이디 중복확인 결과 사용 가능하고
                // 5. 이메일 인증 완료되었을 때
                onPressed: (authState.status == AuthStatus.loading &&
                            !_isCheckingId) ||
                        _isCheckingId || // 중복확인 중에는 비활성화
                        widget.agreedTermIds.isEmpty ||
                        !_isIdValidAndChecked || // 아이디 사용 불가능하면 비활성화
                        !isEmailVerified // 이메일 미인증 시 비활성화
                    ? null
                    : _onRegisterButtonPressed,
              ),
              const SizedBox(height: large),
            ],
          ),
        ),
      ),
    );
  }
}
