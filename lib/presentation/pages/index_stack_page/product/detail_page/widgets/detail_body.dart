import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../domain/product/providers/product_detail_notifier.dart';
import 'detail_item.dart';
import 'detail_item_image.dart';

class DetailBody extends ConsumerWidget {
  final int productId;
  final ScrollController scrollController;

  const DetailBody({
    super.key,
    required this.productId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productDetailState = ref.watch(productDetailProvider(productId));

    return productDetailState.when(
      data: (productDetail) {
        final imagePaths = productDetail.imageUrls ?? [];
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              DetailItemImage(imagePaths: imagePaths),
              DetailItem(productId: productId),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("상품 정보를 불러오지 못했습니다: $err")),
    );
  }
}
