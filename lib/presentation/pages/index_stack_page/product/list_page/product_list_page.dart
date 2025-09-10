import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_app_bar.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_list_body.dart';

import '../write_page/product_write_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  bool _isFilterVisible = false;
  String _currentTitle = "부전제2동";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProductListAppBar(
        currentTitle: _currentTitle,
        onTitleChanged: (newTitle) {
          setState(() {
            _currentTitle = newTitle;
          });
        },
        onFilterToggle: () {
          setState(() {
            _isFilterVisible = !_isFilterVisible;
          });
        },
      ),
      body: ProductListBody(
        isFilterVisible: _isFilterVisible,
        onWritePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductWritePage()),
          );
        },
      ),
    );
  }
}
