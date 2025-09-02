import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_list_item.dart';

class ProductListBody extends StatelessWidget {
  const ProductListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            ProductListItem(),
          ],
        ),
      ),
    );
  }
}
