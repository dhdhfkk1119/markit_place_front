import 'package:flutter/material.dart';
import 'detail_item.dart';
import 'detail_item_image.dart';

class DetailBody extends StatelessWidget {
  final int productId;
  final ScrollController scrollController;

  const DetailBody({
    super.key,
    required this.productId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // productId 기준으로 1~10까지 순환
    final imageIndex = (productId % 10) + 1;
    final imagePath = 'assets/product$imageIndex.png';

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          DetailItemImage(
            imagePaths: [imagePath],
          ),
          DetailItem(productId: productId),
        ],
      ),
    );
  }
}
