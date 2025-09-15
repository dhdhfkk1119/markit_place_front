import 'package:flutter/material.dart';
import '../../../../../../_core/constants/assets.dart';
import 'detail_item.dart';
import 'detail_item_image.dart';

class DetailBody extends StatelessWidget {
  final ScrollController scrollController;

  const DetailBody({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: const Column(
        children: [
          DetailItemImage(
            imagePaths: [
              Images.product,
              Images.product2,
              "assets/product3.jpg",
            ],
          ),
          DetailItem(),
        ],
      ),
    );
  }
}
