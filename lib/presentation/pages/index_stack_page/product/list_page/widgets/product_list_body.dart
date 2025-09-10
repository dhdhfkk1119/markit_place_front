import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_filter_list.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_list_item.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_list_view.dart';
import 'package:markit_place_front/presentation/widgets/WriteButton.dart';

class ProductListBody extends StatelessWidget {
  final bool isFilterVisible;
  final VoidCallback onWritePressed;
  final TextEditingController searchController;
  final bool isSearchVisible;

  const ProductListBody({
    super.key,
    required this.isFilterVisible,
    required this.onWritePressed,
    required this.isSearchVisible,
    required this.searchController,
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
          if (isSearchVisible)
            Positioned(
              top: 0,
              left: isFilterVisible ? 170 : 0, // 필터 있을 때 위치 조정
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "검색어를 입력하세요",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (value) {
                    print("검색: $value");
                  },
                ),
              ),
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
