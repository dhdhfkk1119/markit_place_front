import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_filter_list.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_list_item.dart';

class ProductListBody extends StatefulWidget {
  const ProductListBody({super.key});

  @override
  State<ProductListBody> createState() => _ProductListBodyState();
}

class _ProductListBodyState extends State<ProductListBody>
    with TickerProviderStateMixin {
  bool _isFilterVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Text("부전제2동"),
            SizedBox(width: 4),
            Icon(CupertinoIcons.chevron_down, size: 15.0),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isFilterVisible = !_isFilterVisible;
              });
            },
            icon: const Icon(CupertinoIcons.list_bullet),
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.profile_circled)),
          IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.search)),
          IconButton(
              onPressed: () {}, icon: const Icon(CupertinoIcons.bell_fill)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            // 필터 패널
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation);

                return ClipRect(
                  // <-- layout 보장
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              child: _isFilterVisible
                  ? ConstrainedBox(
                      key: const ValueKey(true),
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: const ProductFilterList(),
                    )
                  : const SizedBox.shrink(key: ValueKey(false)),
            ),

            // 상품 리스트
            Expanded(
              child: const ProductListItem(),
            ),
          ],
        ),
      ),
    );
  }
}
