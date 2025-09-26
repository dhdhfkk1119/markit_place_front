import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../domain/sales/model/sales_model.dart';
import '../../../../../domain/sales/providers/sales_list_provider.dart';
import '../../product/detail_page/detail_page.dart';

class SalesListScreen extends ConsumerStatefulWidget {
  const SalesListScreen({super.key});

  @override
  ConsumerState<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends ConsumerState<SalesListScreen> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        ref.read(salesListProvider.notifier).loadNextPage();
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
    final state = ref.watch(salesListProvider);

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
          title: CustomWidget.buildTitle('판매 내역'),
          centerTitle: true,
          actions: [
            CustomWidget.buildIcon(
              const Icon(Icons.refresh, color: Colors.black),
              onPressed: () async {
                await ref.read(salesListProvider.notifier).refresh();
              },
            ),
          ],
        ),
        body: state.when(
          data: (salesState) {
            if (salesState.items.isEmpty) {
              return const Center(
                child: Text(
                  '판매 내역이 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
                onRefresh: () async {
                  await ref.read(salesListProvider.notifier).refresh();
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: salesState.items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                      productId: salesState.items[index].id),
                                ),
                              );
                            },
                            child: _buildSaleItem(
                              model: salesState.items[index],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ));
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('에러 발생: $err')),
        ));
  }

  Widget _buildSaleItem({required SalesModel model}) {
    final imageBytes = base64ToBytes(model.thumbnailUrl);

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
                  "${model.price}",
                  size: 14,
                  weight: FontWeight.w600,
                  color: Colors.black,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  "${model.status == TradeStatus.ON_SALE ? '판매중' : (model.status == TradeStatus.PENDING ? '예약중' : '판매완료')}",
                  size: 12,
                  color: model.status == TradeStatus.ON_SALE
                      ? Colors.green
                      : (model.status == TradeStatus.PENDING
                          ? Colors.orange // 예약중일 때 주황색 사용
                          : Colors.red), // 나머지 (판매완료)일 때 빨간색 사용
                  weight: FontWeight.w500,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  "${model.createdAt}",
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
