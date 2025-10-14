import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/assets.dart';
import '../../../../../_core/constants/size.dart';
import '../../../../../domain/members/providers/register_provider.dart';
import '../../../../widgets/app_text_form_field.dart';
import '../../../../widgets/custom_button_medium.dart';

class IdVerificationSection extends ConsumerWidget {
  final TextEditingController idController;
  final FocusNode idFocusNode;
  final VoidCallback onCheckIdAvailability;

  const IdVerificationSection({
    Key? key,
    required this.idController,
    required this.idFocusNode,
    required this.onCheckIdAvailability,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerState = ref.watch(registerNotifierProvider);

    final isIdCheckInProgress =
        registerState.status == RegisterStatus.loading &&
            registerState.isIdChecked != true;
    String idFeedbackMessage = "";
    Color idFeedbackColor = Colors.grey;

    if (registerState.status == RegisterStatus.idAvailable) {
      idFeedbackMessage = "사용 가능한 아이디입니다.";
      idFeedbackColor = Colors.green;
    } else if (registerState.status == RegisterStatus.idUnavailable) {
      idFeedbackMessage = registerState.errorMessage ?? "이미 사용 중인 아이디입니다.";
      idFeedbackColor = Colors.red;
    } else if (registerState.status == RegisterStatus.error &&
        registerState.isIdChecked == true) {
      idFeedbackMessage = registerState.errorMessage ?? "아이디 확인 중 오류가 발생했습니다.";
      idFeedbackColor = Colors.red;
    } else if (isIdCheckInProgress) {
      idFeedbackMessage = "확인 중...";
      idFeedbackColor = Colors.grey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextFormField(
                controller: idController,
                focusNode: idFocusNode,
                labelText: '아이디',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '아이디를 입력해주세요.';
                  }
                  if (value.length < 4 || value.length > 20) {
                    return '아이디는 4자 이상 20자 이하로 입력해주세요.';
                  }
                  if (value.contains(' ')) return '아이디에 공백을 포함할 수 없습니다.';
                  return null;
                },
                readOnly: isIdCheckInProgress,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: small, top: small, right: xSmall),
              child: CustomButtonMedium(
                text: '중복확인',
                isLoading: isIdCheckInProgress,
                onPressed: isIdCheckInProgress ? null : onCheckIdAvailability,
              ),
            ),
          ],
        ),
        if (idFeedbackMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 12.0),
            child: Text(
              idFeedbackMessage,
              style: TextStyle(
                color: idFeedbackColor,
                fontSize: 12.0,
                fontFamily: Assets.Fonts.cookieRun,
              ),
            ),
          ),
      ],
    );
  }
}
