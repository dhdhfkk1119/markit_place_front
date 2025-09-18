import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/assets.dart';
import 'package:markit_place_front/_core/constants/custom_popup.dart';

import '../../../../../../domain/product/dtos/product_list_dtos.dart';
import '../../detail_page/detail_page.dart';

class ProductListItem extends ConsumerWidget {
  final ProductListDto product;
  final bool _isFilterVisible;
  ProductListItem(this.product, this._isFilterVisible, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          // 2. MaterialPageRoute를 사용하여 새로운 페이지(DetailPage)를 정의합니다.
          MaterialPageRoute(
            builder: (context) => DetailPage(
                productId: product.id), // DetailPage()는 상세 페이지 위젯입니다.
          ),
        );
      },
      child: SizedBox(
        height: 100,
        child: Row(
          children: [
            _buildProductImage(product.thumbnail),
            const SizedBox(width: 16),
            Expanded(child: _buildProductInfo(product)),
            const SizedBox(width: 8),
            _buildConditionalActions(context),
          ],
        ),
      ),
    );
  }

  // 상품에대한 대표 이미지를 만드는 함수
  Widget _buildProductImage(String? thumbnailUrl) {
    // product.id를 기준으로 1~10까지 순환
    final imageIndex = (product.id % 10) + 1;
    final imagePath = 'assets/product$imageIndex.jpg';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        imagePath,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
    );
  }

  // 조건부에 따라 오른쪽 (list-button,bottom Icon) 위치 조정
  Widget _buildConditionalActions(BuildContext context) {
    if (_isFilterVisible) {
      return const SizedBox.shrink();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) {
                    return CustomPopUp.buildAppBarPopUp(
                        context, "조정우", "상품제목을입력", 1);
                  },
                );
              },
              child: const Icon(
                Icons.more_vert,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ),
          _buildBottomIcon(),
        ],
      );
    }
  }

  // 상품에 대한 정보를 담음 함수(제목, 위치,가격)
  Widget _buildProductInfo(ProductListDto product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(product.title, 16),
        Text(
          "${product.tradeLocation} / ${product.itemCategoryName}",
          style: TextStyle(fontSize: 14, color: Colors.grey),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: false,
        ),
        _buildTitle("가격 : ${product.price}원", 14, font: FontWeight.w200),
      ],
    );
  }

  Widget _buildTitle(String title, double size,
      {FontWeight? font, Color? color}) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: Assets.Fonts.cookieRun,
        fontSize: size,
        color: color ?? Colors.black,
        fontWeight: font ?? FontWeight.w700,
      ),
    );
  }

  Widget _buildBottomIcon() {
    return Row(
      children: [
        _buildIcon(CupertinoIcons.profile_circled),
        _buildTitle("14", 12, font: FontWeight.w200, color: Colors.grey),
        const SizedBox(
          width: 5,
        ),
        _buildIcon(CupertinoIcons.heart_fill),
        _buildTitle("14", 12, font: FontWeight.w200, color: Colors.grey),
      ],
    );
  }

  Widget _buildIcon(IconData? icon) {
    return Icon(
      icon,
      size: 14,
      color: Colors.grey,
    );
  }
}
