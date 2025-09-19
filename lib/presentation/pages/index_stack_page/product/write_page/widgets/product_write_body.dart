import 'package:flutter/cupertino.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/write_page/widgets/product_write_item.dart';

class ProductWriteBody extends StatefulWidget {
  const ProductWriteBody({super.key});

  @override
  State<ProductWriteBody> createState() => _ProductWriteBodyState();
}

class _ProductWriteBodyState extends State<ProductWriteBody> {
  @override
  Widget build(BuildContext context) {
    return ProductWriteItem();
  }
}
