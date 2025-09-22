import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../domain/product/dtos/product_detail_dto.dart';
import '../../../../../../domain/product/providers/product_detail_notifier.dart';
import 'detail_item_image.dart';
import '../../../../../../_core/constants/custom_widget.dart';

class DetailItem extends ConsumerWidget {
  final int productId;
  const DetailItem({required this.productId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productDetailProvider(productId));

    return productState.when(
      data: (product) {
        print("상품 상세 페이지 유저의 정보들 : ${product.retransactionRate}");
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfile(product, context),
                    _buildDivider(),
                    CustomWidget.buildTitle(
                      "${product.productList.title}",
                      size: 20,
                    ),
                    CustomWidget.buildTitle(
                      "${product.productList.price}",
                      size: 20,
                    ),
                    CustomWidget.buildTitle(
                      "${product.productList.itemCategoryName}",
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${product.productList.content}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("상품 정보를 불러오는 중 오류 발생: $err")),
    );
  }

  Widget _buildProfile(ProductDetailDto dto, BuildContext context) {
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // 프로필 이미지를 위한 전용 함수 호출
              _buildProfileImage(dto.sellerProfileUrl),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.buildTitle("${dto.sellerName}",
                        size: 16, weight: FontWeight.w500),
                    CustomWidget.buildTitle("${dto.sellerAddress}",
                        size: 12, color: Colors.grey, weight: FontWeight.w200),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomWidget.buildTitle("${dto.retransactionRate} 점",
                  size: 16, weight: FontWeight.w500),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) {
                      return _buildBottomPopUp(context);
                    },
                  );
                },
                child: CustomWidget.buildTitle("평균점수",
                    size: 12,
                    weight: FontWeight.w200,
                    color: Colors.grey,
                    decoration: TextDecoration.underline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildBottomPopUp(BuildContext context) {
    // ... 기존 코드와 동일
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20),
              child: CustomWidget.buildTitle("평균 점수 란?"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomWidget.buildTitle(
                  "당신이 사용자로부터 상품을 판매하고 받은 리뷰 점수를 바탕으로 통계를 내린 매너 지표입니다",
                  weight: FontWeight.w100,
                  color: Colors.black54,
                  overflow: TextOverflow.clip),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: CustomWidget.buildTitle("확인",
                      size: 16, weight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String? thumbnailUrl) {
    final imageBytes = base64ToBytes(thumbnailUrl);

    if (imageBytes == null) {
      return _buildDefaultProfileImage();
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          imageBytes,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  // 기본 프로필 이미지를 반환하는 헬퍼 함수
  Widget _buildDefaultProfileImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Image.asset(
        Assets.Images.defaultProfile,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    );
  }
}
