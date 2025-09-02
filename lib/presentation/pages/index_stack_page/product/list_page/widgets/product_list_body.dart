import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_fiter_list.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_list_item.dart';

class ProductListBody extends StatefulWidget {
  const ProductListBody({super.key});

  @override
  State<ProductListBody> createState() => _ProductListBodyState();
}

class _ProductListBodyState extends State<ProductListBody> {
  bool _isFilterVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  child: child,
                );
              },
              child: _isFilterVisible
                  ? Expanded(
                      key: const ValueKey<bool>(true),
                      flex: 3,
                      child: ProductFiterList(),
                    )
                  : SizedBox(
                      key: const ValueKey<bool>(false),
                      width: 0,
                    ),
            ),
            Expanded(
              flex: 7,
              child: ProductListItem(),
            ),
          ],
        ),
      ),
    );
  }
}
