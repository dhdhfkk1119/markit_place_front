import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_filter_list.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_list_item.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_list_view.dart';
import 'package:markit_place_front/presentation/widgets/WriteButton.dart';

class ProductListBody extends StatelessWidget {
  final bool isFilterVisible;
  final VoidCallback onWritePressed;

  const ProductListBody({
    super.key,
    required this.isFilterVisible,
    required this.onWritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Row(
            children: [
              if (isFilterVisible)
                const SizedBox(
                    width: 170,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ProductFilterList(),
                    )),
              Expanded(
                child: ListView.separated(
                  itemCount: 10,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ProductListItem(isFilterVisible),
                  ),
                  separatorBuilder: (_, __) => const Divider(
                    height: 32,
                    thickness: 1,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          WriteButton(
            onTap: onWritePressed,
            title: "상품등록",
          ),
        ],
      ),
    );
  }
}
