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
    final imagePath = productDetailState.productDetail?.imageUrls ?? [];

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          DetailItemImage(
            imagePaths: imagePath,
          ),
          DetailItem(productId: productId),
        ],
      ),
    );
  }
}
