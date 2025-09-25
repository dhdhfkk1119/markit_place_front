import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../domain/product/dtos/product_detail_dto.dart';

class ReportDetailProductCard extends StatelessWidget {
  final AsyncValue<ProductDetailDto> dto;

  const ReportDetailProductCard({
    super.key,
    required this.dto,
  });

  @override
  Widget build(BuildContext context) {
    return dto.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Text('상품 정보를 불러오지 못했습니다\n$err',
            style: const TextStyle(color: Colors.red)),
      ),
      data: (product) {
        final item = product.productList;
        final imageToBytes = base64ToBytes(item.thumbnail);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0x11000000)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: item.thumbnail != null && item.thumbnail!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(imageToBytes!, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.shopping_bag_outlined,
                        size: 34, color: Color(0xFFBDBDBD)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('${item.price}원',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text("${item.itemCategoryName}" ?? '위치 정보 없음',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
