import 'package:flutter/cupertino.dart';
import '../../../../../../domain/product/dtos/product_detail_dto.dart';
import 'product_write_item.dart';

class ProductWriteBody extends StatefulWidget {
  ProductDetailDto? model;
  ProductWriteBody({this.model, super.key});

  @override
  State<ProductWriteBody> createState() => _ProductWriteBodyState();
}

class _ProductWriteBodyState extends State<ProductWriteBody> {
  @override
  Widget build(BuildContext context) {
    return ProductWriteItem(model: widget.model);
  }
}
