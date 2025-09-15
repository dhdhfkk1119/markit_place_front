import 'package:flutter/material.dart';
import '../../../../_core/constants/assets.dart';
import 'widgets/find_account_body.dart'; // 수정된 경로

// 아이디/비밀번호 찾기 페이지 위젯 (탭 구조)
class FindAccountPage extends StatelessWidget {
  const FindAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2, // 탭 개수: 아이디 찾기, 비밀번호 초기화
      child: Scaffold(
        appBar: AppBar(
          title: Text('아이디/비밀번호 찾기',
              style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary, // 테마의 primary 색상 사용
            labelColor: theme.colorScheme.primary, // 테마의 primary 색상 사용
            unselectedLabelColor:
                theme.textTheme.bodySmall?.color, // 선택되지 않은 탭 레이블 색상
            tabs: const [
              Tab(text: '아이디 찾기'),
              Tab(text: '비밀번호 초기화'),
            ],
          ),
        ),
        body:
            const FindAccountBody(), // AppBar를 제외한 본문 내용을 FindAccountBody 위젯으로 분리
      ),
    );
  }
}
