import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/auth/terms_page/widgets/terms_body.dart';

// 약관 동의 페이지 (경로, AppBar, 제목 담당)
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new), // 뒤로가기 아이콘
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
            '약관동의'), // AppBar 제목. CookieRun 폰트 적용은 여기서 제외하거나, 필요시 TextStyle 추가
        centerTitle: true,
        // AppBar 하단 구분선 추가
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            color: Colors.grey.shade300,
            height: 1.0,
            thickness: 1.0,
          ),
        ),
      ),
      body: const TermsBody(), // 페이지 본문은 TermsBody 위젯에서 관리
    );
  }
}
