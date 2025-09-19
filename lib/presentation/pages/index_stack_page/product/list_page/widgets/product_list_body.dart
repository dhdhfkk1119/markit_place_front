import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../domain/product/providers/product_list_notifier.dart';
import 'product_filter_list.dart';
import 'product_list_item.dart';
import '../../../../../widgets/WriteButton.dart';

class ProductListBody extends ConsumerStatefulWidget {
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
  ConsumerState<ConsumerStatefulWidget> createState() => _ProductListState();
}

class _ProductListState extends ConsumerState<ProductListBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListProvider.notifier).getProductList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(productListProvider);

    // 2. 로딩 상태와 데이터, 에러 상태를 감지합니다.
    if (notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifier.errorMessage != null) {
      return Center(child: Text('에러: ${notifier.errorMessage}'));
    }

    final productList = notifier.productList;

    return SafeArea(
      child: Stack(
        children: [
          Row(
            children: [
              if (widget.isFilterVisible)
                const SizedBox(
                    width: 170,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ProductFilterList(),
                    )),
              Expanded(
                child: productList.isEmpty
                    ? const Center(
                        child: Text(
                          "리스트가 없습니다.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: productList.length,
                        itemBuilder: (context, index) {
                          final product = productList[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ProductListItem(
                                product, widget.isFilterVisible),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(
                          height: 32,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ],
          ),
          if (widget.isSearchVisible)
            Positioned(
              top: 0,
              left: widget.isFilterVisible ? 170 : 0, // 필터 있을 때 위치 조정
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: widget.searchController,
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
            onTap: widget.onWritePressed,
            title: "상품등록",
          ),
        ],
      ),
    );
  }
}
