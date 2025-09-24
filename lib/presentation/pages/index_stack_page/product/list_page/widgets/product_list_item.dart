import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../_core/constants/custom_popup.dart';

import '../../../../../../domain/product/dtos/product_list_dtos.dart';
import '../../../../../../domain/product/providers/product_detail_notifier.dart';
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
            _buildProductImage(product),
            const SizedBox(width: 16),
            Expanded(child: _buildProductInfo(product)),
            const SizedBox(width: 8),
            _buildConditionalActions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductListDto product) {
    if (product.thumbnail == null || product.thumbnail!.isEmpty) {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, size: 50),
      );
    }

    final bytes = base64ToBytes(product.thumbnail);

    if (bytes == null) {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[200],
        child: const Icon(Icons.error_outline, size: 50, color: Colors.red),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.black54,
                ),
              );
            },
          ),
        ),
        if (product.status == "SOLD")
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withOpacity(0.4),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -0.4,
                  child: const Text(
                    "SOLD",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConditionalActions(BuildContext context, WidgetRef ref) {
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
              onTap: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false, // 사용자가 닫을 수 없게 합니다.
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
                try {
                  await ref.read(productDetailProvider(product.id).future);

                  Navigator.pop(context);

                  _showProductPopup(context, ref, product);
                } catch (e) {
                  // 로딩 실패 시 에러 처리 (예: 스낵바 표시)
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("상품 정보를 불러오지 못했습니다.")),
                  );
                }
              },
              child: const Icon(
                Icons.more_vert,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ),
          _buildBottomIcon(product),
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
          product.itemCategoryName,
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

  Widget _buildBottomIcon(ProductListDto dto) {
    return Row(
      children: [
        _buildIcon(CupertinoIcons.profile_circled),
        _buildTitle("${dto.viewCount}", 12,
            font: FontWeight.w200, color: Colors.grey),
        const SizedBox(
          width: 5,
        ),
        _buildIcon(CupertinoIcons.heart_fill),
        _buildTitle("${dto.favoriteCount}", 12,
            font: FontWeight.w200, color: Colors.grey),
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

  void _showProductPopup(
      BuildContext context, WidgetRef ref, ProductListDto product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // 이 시점에는 이미 데이터가 로딩되어 있으므로, 팝업이 바로 내용을 표시합니다.
        return CustomPopUp.buildAppBarPopUp(
            context, "${product.title}", "${product.content}", product.id,
            ref: ref);
      },
    );
  }
}
