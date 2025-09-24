import 'package:flutter/material.dart';
import '../../../../../../domain/report/report_dto/product_report_dto.dart';
import 'report_list_item.dart';

class ReportListView extends StatelessWidget {
  const ReportListView({
    super.key,
    required this.items,
    required this.onTapItem,
  });

  final List<ProductReportDto> items;
  final void Function(ProductReportDto) onTapItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(), // ★ 빈화면에서도 pull-to-refresh 동작
        children: const [
          SizedBox(height: 200),
          Center(
            child: Text('신고 내역이 없습니다.', style: TextStyle(color: Colors.grey)),
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
      itemBuilder: (context, int index) {
        final dto = items[index];
        return ReportListItem(
          key: ValueKey(dto.id),
          title: '신고 상품 게시물 ${dto.id}',
          reason: dto.reason,
          status: dto.status.name,
          createdAt: dto.createdAt,
          thumbnailUrl: dto.thumbnailUrl,
          onTap: dto.id >= 0 ? () => onTapItem(dto) : null,
        );
      },
    );
  }
}
