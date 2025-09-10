import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_list_item.dart';

import '../../../../../../_core/constants/custom_widget.dart';

class ProductListView extends StatelessWidget {
  final bool isFilterVisible;

  const ProductListView({super.key, required this.isFilterVisible});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      itemBuilder: (context, index) => ProductListItem(isFilterVisible),
      separatorBuilder: (_, __) => const Divider(
        height: 32,
        thickness: 1,
        color: Colors.grey,
      ),
    );
  }
}
