import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart';
import 'package:markit_place_front/_core/constants/assets.dart';
// Provider import
import 'package:markit_place_front/domain/members/providers/password_reset_provider.dart';
// Validator import
import 'package:markit_place_front/_core/utils/validator_util.dart';

class ResetPasswordForm extends ConsumerStatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  ConsumerState<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _loginIdController = TextEditingController(text: 'user1');
  final _emailController =
      TextEditingController(text: 'choongechobiz@gmail.com');
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    _loginIdController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Widget _buildIdentifierStep(
      PasswordResetState state, PasswordResetNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '가입 시 사용한 로그인 ID와 이메일 주소를 입력해주세요.',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontFamily: Assets.Fonts.cookieRun),
        ),
        const SizedBox(height: small), // size.dart에 small_gap 대신 small 사용
        Text(
          '계정 확인 후 인증 코드를 발송합니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: Assets.Fonts.cookieRun, color: Colors.grey[700]),
        ),
        const SizedBox(height: medium),
        TextFormField(
          controller: _loginIdController,
          decoration: const InputDecoration(
            hintText: '로그인 ID 입력',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '로그인 ID를 입력해주세요.';
            }
            return null;
          },
        ),
        const SizedBox(height: medium),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: '이메일 주소 입력',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final emailError = validateEmail(value ?? "");
            return emailError.isEmpty ? null : emailError;
          },
        ),
        const SizedBox(height: xLarge),
        CustomButtonLarge(
          text: '인증 코드 발송',
          isLoading: state.isLoading,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              notifier.sendPasswordResetCode(
                  _loginIdController.text, _emailController.text);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('입력 내용을 다시 확인해주세요.',
                      style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildCodeConfirmationStep(
      PasswordResetState state, PasswordResetNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${state.emailForCodeConfirmation?.isNotEmpty == true ? state.emailForCodeConfirmation : "입력하신 이메일"}(으)로 발송된 6자리 인증 코드를 입력해주세요.',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontFamily: Assets.Fonts.cookieRun),
        ),
        const SizedBox(height: small),
        Text(
          '이메일을 확인하여 코드를 입력하고, 다음 단계로 진행하세요.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: Assets.Fonts.cookieRun, color: Colors.grey[700]),
        ),
        const SizedBox(height: medium),
        TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(
            hintText: '인증 코드 6자리 입력',
            border: OutlineInputBorder(),
            counterText: "", // maxLength 시 기본으로 생기는 카운터 텍스트 제거
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '인증 코드를 입력해주세요.';
            }
            if (value.length != 6) {
              return '인증 코드는 6자리입니다.';
            }
            return null;
          },
        ),
        const SizedBox(height: xLarge),
        CustomButtonLarge(
          text: '인증 코드 확인',
          isLoading: state.isLoading,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              notifier.confirmPasswordResetCode(_codeController.text);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('입력 내용을 다시 확인해주세요.',
                      style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep(
      PasswordResetState state, PasswordResetNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '새로운 비밀번호를 입력해주세요.',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontFamily: Assets.Fonts.cookieRun),
        ),
        const SizedBox(height: small),
        Text(
          '비밀번호는 4자 이상 12자 이하로 설정해주세요.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: Assets.Fonts.cookieRun, color: Colors.grey[700]),
        ),
        const SizedBox(height: medium),
        TextFormField(
          controller: _newPasswordController,
          decoration: const InputDecoration(
            hintText: '새 비밀번호 (4~12자)',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            final passwordError = validatePassword(value ?? "");
            return passwordError.isEmpty ? null : passwordError;
          },
        ),
        const SizedBox(height: medium),
        TextFormField(
          controller: _confirmNewPasswordController,
          decoration: const InputDecoration(
            hintText: '새 비밀번호 확인',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '새 비밀번호를 다시 입력해주세요.';
            }
            if (value != _newPasswordController.text) {
              return '새 비밀번호가 일치하지 않습니다.';
            }
            return null;
          },
        ),
        const SizedBox(height: xLarge),
        CustomButtonLarge(
          text: '비밀번호 재설정',
          isLoading: state.isLoading,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              notifier.resetPassword(_newPasswordController.text,
                  _confirmNewPasswordController.text);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('입력 내용을 다시 확인해주세요.',
                      style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSuccessStep(
      PasswordResetState state, PasswordResetNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 50),
          const SizedBox(height: medium),
          Text(
            '비밀번호가 성공적으로 재설정되었습니다.',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontFamily: Assets.Fonts.cookieRun),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: small),
          Text(
            '이제 새로운 비밀번호로 로그인할 수 있습니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: Assets.Fonts.cookieRun, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: xLarge),
          CustomButtonLarge(
            text: '로그인 페이지로 이동',
            onPressed: () {
              notifier.resetToInitial();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/account-login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStep(
      PasswordResetState state, PasswordResetNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              color: Theme.of(context).colorScheme.error, size: 50),
          const SizedBox(height: medium),
          Text(
            state.errorMessage ?? '오류가 발생했습니다. 다시 시도해주세요.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: Assets.Fonts.cookieRun,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: small),
          Text(
            '문제가 지속되면 관리자에게 문의해주세요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: Assets.Fonts.cookieRun, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: xLarge),
          CustomButtonLarge(
            text: '처음으로 돌아가기',
            onPressed: () {
              notifier.resetToInitial();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetProvider);
    final notifier = ref.read(passwordResetProvider.notifier);

    ref.listen<PasswordResetState>(passwordResetProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage!.isNotEmpty &&
          (previous?.errorMessage != next.errorMessage ||
              (previous?.step != next.step &&
                  next.step != PasswordResetStep.error))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage!,
              style: TextStyle(fontFamily: Assets.Fonts.cookieRun),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.all(medium),
      child: Form(
        key: _formKey,
        child: Builder(
          builder: (context) {
            switch (state.step) {
              case PasswordResetStep.enterIdentifier:
                return _buildIdentifierStep(state, notifier);
              case PasswordResetStep.enterCode:
                return _buildCodeConfirmationStep(state, notifier);
              case PasswordResetStep.enterNewPassword:
                return _buildNewPasswordStep(state, notifier);
              case PasswordResetStep.success:
                return _buildSuccessStep(state, notifier);
              case PasswordResetStep.error:
                return _buildErrorStep(state, notifier);
              default:
                return _buildIdentifierStep(state, notifier);
            }
          },
        ),
      ),
    );
  }
}
