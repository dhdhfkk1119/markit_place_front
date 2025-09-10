import 'package:flutter/cupertino.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/write_page/widgets/product_write_item.dart';

class ProductWriteBody extends StatefulWidget {
  const ProductWriteBody({super.key});

  @override
  State<ProductWriteBody> createState() => _ProductWriteBodyState();
}

class _ProductWriteBodyState extends State<ProductWriteBody> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return const ProductWriteItem();
  }
}
