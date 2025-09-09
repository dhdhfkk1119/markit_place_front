import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/auth/input_page/widgets/input_form.dart';

class InputBody extends StatelessWidget {
  const InputBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0), // 전체적인 패딩
      child: InputForm(),
    );
  }
}
