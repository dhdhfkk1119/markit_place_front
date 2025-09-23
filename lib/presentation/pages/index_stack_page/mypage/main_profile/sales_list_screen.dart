import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../domain/sales/model/sales_model.dart';
import '../../../../../domain/sales/providers/sales_list_provider.dart';

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

    return state.when(
      data: (salesState) {
        final List<SalesModel> sales = salesState.items;

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
          ),
          body: RefreshIndicator(
              onRefresh: () async {
                await ref.read(salesListProvider.notifier).refresh();
              },
              child: ListView.builder(
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final item = sales[index];
                  return _buildSaleItem(
                    title: item.title,
                    status: item.statusLabel,
                    price: '${item.price} 원',
                    date: item.createdAt,
                    thumbnailUrl: item.thumbnailUrl,
                  );
                },
              )),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('에러 발생: $err')),
    );
  }

  Widget _buildSaleItem({
    required String title,
    required String status,
    required String price,
    required String date,
    String? thumbnailUrl,
  }) {
    final imageBytes = base64ToBytes(thumbnailUrl);
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
                  title,
                  size: 16,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  price,
                  size: 14,
                  weight: FontWeight.w600,
                  color: Colors.black,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  status,
                  size: 12,
                  color: status == '판매중' ? Colors.green : Colors.red,
                  weight: FontWeight.w500,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  date,
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
