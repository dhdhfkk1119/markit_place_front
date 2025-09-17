import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart'; // CustomWidget import

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

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
          '공지사항 메인화면',
          color: Colors.black,
        ),
        centerTitle: true,
        actions: [
          CustomWidget.buildIcon(
            const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              // TODO: 새로고침 기능 구현
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNoticeItem(
              type: '[공지]',
              title: '해외직구 전자기기 중고거래 유의사항 안내',
              date: '2025. 08. 11',
            ),
            _buildNoticeItem(
              type: '[공지]',
              title: '마켓플레이스 서비스 점검 일정 안내해드려요.\n(8월 13일 수요일 03:00~04:00)',
              date: '2025. 08. 08',
            ),
            _buildNoticeItem(
              type: '[공지]',
              title: '잘못된 세척기 거래 주의 안내',
              date: '2025. 08. 07',
            ),
            _buildNoticeItem(
              type: '[공지]',
              title: '수산용 동물용의약품 온라인 구매 금지 안내',
              date: '2025. 08. 03',
            ),
            _buildNoticeItem(
              type: '[공지]',
              title: '민생회복 소비쿠폰 재판매 금지 안내',
              date: '2025. 07. 28',
            ),
            _buildNoticeItem(
              type: '[공지]',
              title: '사용자 권리 보장을 강화하기 위해 마켓 플레이스\n개인정보처리방침이 변경될 예정이에요.',
              date: '2025. 07. 18',
            ),
            _buildNoticeItem(
              type: '[공지]',
              title: '마켓페이 위치기반서비스 이용약관이 개정될\n예정이에요.',
              date: '2025. 07. 14',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeItem({required String type, required String title, required String date}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomWidget.buildTitle(
                type,
                size: 14,
                weight: FontWeight.w700,
              ),
              const SizedBox(width: 8),
              CustomWidget.buildTitle(
                title,
                size: 14,
                weight: FontWeight.normal,
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomWidget.buildTitle(
            date,
            size: 12,
            color: Colors.grey[600],
            weight: FontWeight.w200,
          ),
        ],
      ),
    );
  }
}