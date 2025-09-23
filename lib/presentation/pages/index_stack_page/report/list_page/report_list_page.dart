import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../../../../_core/constants/custom_widget.dart';
import '../detail_page/report_detail_page.dart';

class ReportListPage extends StatelessWidget {
  const ReportListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomWidget.buildIcon(
          const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: CustomWidget.buildTitle('신고 내역'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(
            10,
            (index) => _buildReportItem(
              context,
              title: '신고 상품 게시물 ${index + 1}',
              reason: '욕설 게시글을 작성 하였습니다.확인 부탁드립니다.',
              status: index % 2 == 0 ? '보류중' : '제재완료',
              createdAt: '2025.08.${20 + index}',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportItem(
    BuildContext context, {
    required String title,
    required String reason,
    required String status,
    required String createdAt,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ReportDetailPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.photo, color: Colors.grey)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.buildTitle(
                    title,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  CustomWidget.buildTitle(
                    reason,
                    size: 14,
                    weight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 4),
                  CustomWidget.buildTitle(
                    status,
                    size: 12,
                    color: status == '제재완료' ? Colors.blue : Colors.purple,
                    weight: FontWeight.w500,
                  ),
                  const SizedBox(height: 4),
                  CustomWidget.buildTitle(
                    createdAt,
                    size: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
