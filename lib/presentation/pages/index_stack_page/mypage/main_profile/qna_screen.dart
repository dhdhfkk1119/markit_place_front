import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';

class QnaScreen extends StatefulWidget {
  const QnaScreen({super.key});

  @override
  State<QnaScreen> createState() => _QnaScreenState();
}

class _QnaScreenState extends State<QnaScreen> {
  // TODO: 여기에 Q&A 리스트 데이터를 관리할 변수 추가

  Future<void> _refreshData() async {
    // TODO: 여기에 백엔드 API를 호출하여 최신 Q&A 데이터를 가져오는 로직 구현
    print("데이터 새로고침 요청됨!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomWidget.buildIcon(
          const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: CustomWidget.buildTitle(
          '고객 센터',
          color: Colors.black,
        ),
        centerTitle: true,
        actions: [
          CustomWidget.buildIcon(
            const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              _refreshData(); // 새로고침 기능 호출
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildQnaItem(
                  title: '상품이 잘못 도착했어요. 어떻게 해야 하나요?',
                  date: '2025. 08. 13',
                ),
                _buildQnaItem(
                  title: '계정을 삭제하고 싶어요.',
                  date: '2025. 08. 11',
                ),
                _buildQnaItem(
                  title: 'MP PAY 충전이 안돼요.',
                  date: '2025. 08. 08',
                ),
                _buildQnaItem(
                  title: '비밀번호를 잊어버렸어요.',
                  date: '2025. 08. 07',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQnaItem({required String title, required String date}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.buildTitle(
                  '[문의]',
                  size: 14,
                  weight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  title,
                  size: 16,
                  weight: FontWeight.normal,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  date,
                  size: 12,
                  color: Colors.grey[600],
                  weight: FontWeight.normal,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}