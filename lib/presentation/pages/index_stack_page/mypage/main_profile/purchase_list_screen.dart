import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../domain/trade/model/trade_model.dart';
import '../../../../../domain/trade/provider/trade_provider.dart';
import '../../product/detail_page/detail_page.dart';

class PurchaseListScreen extends ConsumerStatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  ConsumerState<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends ConsumerState<PurchaseListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        ref.read(tradeProvider.notifier).loadNextPage();
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
    final state = ref.watch(tradeProvider);

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
        title: CustomWidget.buildTitle('구매 내역'),
        centerTitle: true,
        actions: [
          CustomWidget.buildIcon(
            const Icon(Icons.refresh, color: Colors.black),
            onPressed: () async {
              await ref.read(tradeProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: state.when(
        data: (tradeList) {
          final List<TradeListModel> trade = tradeList.items;

          if (trade.isEmpty) {
            return const Center(
              child: Text(
                '구매 내역이 없습니다',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(tradeProvider.notifier).refresh();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: trade.length,
              itemBuilder: (context, index) {
                final item = trade[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPage(productId: tradeList.items[index].id),
                        ),
                      );
                    },
                    child: _buildPurchaseItem(
                      model: item,
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러 발생: $err')),
      ),
    );
  }

  Widget _buildPurchaseItem({required TradeListModel model}) {
    final imageBytes = base64ToBytes(model.thumbnailUrl);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상품 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Center(
                            child: Icon(Icons.photo, color: Colors.grey)),
                      ),
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
                      model.status,
                      size: 12,
                      color:
                          model.status == '구매완료' ? Colors.blue : Colors.purple,
                      weight: FontWeight.w500,
                    ),
                    const SizedBox(height: 4),
                    CustomWidget.buildTitle(
                      model.completedAt ?? '----/--/--',
                      size: 12,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          // 리뷰 섹션
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // TODO: 리뷰 작성 페이지로 이동 또는 다이얼로그 표시
                  print('리뷰작성 버튼 클릭: ${model.id}');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text(
                  '리뷰작성',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    '아직 작성된 리뷰가 없습니다.', // 리뷰 첫 문장 (플레이스홀더)
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
