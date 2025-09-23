import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../domain/trade/model/trade_model.dart';
import '../../../../../domain/trade/provider/trade_provider.dart';

class PurchaseListScreen extends ConsumerStatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  ConsumerState<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends ConsumerState<PurchaseListScreen> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {});
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
      ),
      body: state.when(
        data: (tradeList) {
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(tradeProvider.notifier).refresh();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: tradeList.length,
              itemBuilder: (context, index) {
                final item = tradeList[index];
                return _buildPurchaseItem(
                  model: item,
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
                  model.status,
                  size: 12,
                  color: model.status == '구매완료' ? Colors.blue : Colors.purple,
                  weight: FontWeight.w500,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  model.completedAt,
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
