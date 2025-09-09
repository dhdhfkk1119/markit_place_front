import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/auth/input_page/widgets/input_body.dart';

class InputPage extends StatelessWidget {
  const InputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'), // 시안에 따른 제목
        bottom: PreferredSize(
          // 밑줄 효과
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300], // 밑줄 색상
            height: 1.0,
          ),
        ),
        leading: IconButton(
          // 뒤로가기 버튼
          icon: const Icon(Icons.arrow_back_ios), // iOS 스타일 뒤로가기 아이콘 (변경 가능)
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: const InputBody(),
    );
  }
}
