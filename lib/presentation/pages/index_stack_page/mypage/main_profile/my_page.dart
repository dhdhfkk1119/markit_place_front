import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/mypage/main_profile/widgets/my_page_body.dart';

import '../../../../../_core/constants/assets.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // 뒤로 가기 동작
          },
        ),
        title: const Text(
          '나의 MP 마당',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontFamily: Fonts.cookieRun,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.grey),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const MyPageBody(),
    );
  }
}
