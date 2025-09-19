import 'package:flutter/material.dart';
import 'widgets/terms_body.dart';

import '../../../../_core/constants/assets.dart';

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
        title:
            Text('약관동의', style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
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
