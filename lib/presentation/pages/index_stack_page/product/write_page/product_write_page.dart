import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/write_page/widgets/product_write_body.dart';

class ProductWritePage extends StatelessWidget {
  const ProductWritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProductWriteBody(),
    );
  }
}
