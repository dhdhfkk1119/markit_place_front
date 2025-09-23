import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../domain/favorite/model/product_favorite.dart';
import '../../../../../domain/favorite/provider/product_favorite_notifier.dart';
import '../../product/detail_page/detail_page.dart';

class FavoriteListScreen extends ConsumerStatefulWidget {
  const FavoriteListScreen({super.key});

  @override
  ConsumerState<FavoriteListScreen> createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends ConsumerState<FavoriteListScreen> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        ref.read(productFavoriteListProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productFavoriteListProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomWidget.buildIcon(
          const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: CustomWidget.buildTitle('관심 목록'),
        centerTitle: true,
        actions: [
          CustomWidget.buildIcon(
            const Icon(Icons.refresh, color: Colors.black),
            onPressed: () async {
              await ref.read(productFavoriteListProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: state.when(
        data: (favoriteList) {
          if (favoriteList.items.isEmpty) {
            return const Center(
              child: Text(
                '좋아요 내역이 없습니다',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(productFavoriteListProvider.notifier).refresh();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: favoriteList.items.length,
              itemBuilder: (context, index) {
                final item = favoriteList.items[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(productId: item.itemId),
                            ),
                          );
                        },
                        child: _buildFavoriteItem(model: item),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('에러 발생: $err'),
        ),
      ),
    );
  }

  Widget _buildFavoriteItem({required ProductFavoriteModel model}) {
    final imageBytes = base64ToBytes(model?.thumbnailUrl);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지
          if (imageBytes != null)
            Image.memory(
              imageBytes,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            )
          else
            Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.photo, color: Colors.grey)),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.buildTitle(
                  model.title,
                  size: 16,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  model.title,
                  size: 12,
                  color: Colors.grey,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  "${model.price}원" ?? '0',
                  size: 14,
                  weight: FontWeight.w600,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(Icons.favorite, size: 20, color: Colors.red),
              CustomWidget.buildTitle(
                "${model.favoriteCount}" ?? '0',
                size: 12,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
