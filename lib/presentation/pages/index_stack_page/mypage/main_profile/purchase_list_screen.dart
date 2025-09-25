import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../domain/trade/model/trade_model.dart';
import '../../../../../domain/trade/provider/trade_provider.dart';
import '../../../../../domain/trade_review/trade_review_dto.dart';
import '../../../../../domain/trade_review/trade_review_provider.dart';
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

    ref.listen<AsyncValue>(tradeReviewProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰 작성 실패: ${next.error}')),
        );
      } else if (next.hasValue && next.value != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 성공적으로 작성되었습니다!')),
        );
        ref.read(tradeProvider.notifier).refresh();
      }
    });

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
                      // API 명세에 따라 상품 ID는 itemId를 사용합니다.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPage(productId: item.itemId),
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
    // API 명세에 따라 itemThumbnail 필드를 사용합니다.
    final imageBytes = base64ToBytes(model.itemThumbnail);

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
                    // API 명세에 따라 필드 이름들을 수정합니다.
                    CustomWidget.buildTitle(model.itemTitle, size: 16),
                    const SizedBox(height: 4),
                    CustomWidget.buildTitle("${model.price}",
                        size: 14, weight: FontWeight.w600, color: Colors.black),
                    const SizedBox(height: 4),
                    CustomWidget.buildTitle(model.tradeStatus,
                        size: 12,
                        color: model.tradeStatus == 'COMPLETED'
                            ? Colors.blue
                            : Colors.purple,
                        weight: FontWeight.w500),
                    const SizedBox(height: 4),
                    CustomWidget.buildTitle(model.tradedAt,
                        size: 12, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildReviewSection(model),
        ],
      ),
    );
  }

  Widget _buildReviewSection(TradeListModel model) {
    // API 명세에 따라 isReviewed 필드를 사용하여 리뷰 작성 여부를 판단합니다.
    final bool hasReview = model.isReviewed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: hasReview
              ? null
              : () {
                  // API 명세에 따라 tradeId를 넘겨줍니다.
                  showDialog(
                    context: context,
                    builder: (context) =>
                        _ReviewFormDialog(tradeId: model.tradeId),
                  );
                },
          style: TextButton.styleFrom(
            backgroundColor: hasReview ? Colors.grey[300] : Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Text(hasReview ? '작성완료' : '리뷰작성',
              style: TextStyle(
                  color: hasReview ? Colors.grey[600] : Colors.black,
                  fontSize: 12)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              hasReview ? '작성된 리뷰가 있습니다.' : '아직 작성된 리뷰가 없습니다.',
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewFormDialog extends ConsumerStatefulWidget {
  final int tradeId;

  const _ReviewFormDialog({required this.tradeId});

  @override
  ConsumerState<_ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends ConsumerState<_ReviewFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(tradeReviewProvider).isLoading;

    return AlertDialog(
      title: const Text('리뷰 작성'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLength: 100,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '리뷰 내용을 입력해주세요.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '내용을 입력해주세요.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: isSubmitting
              ? null
              : () {
                  if (_rating == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('별점을 선택해주세요.')),
                    );
                    return;
                  }
                  if (_formKey.currentState!.validate()) {
                    final reviewDto = TradeReviewRequestDto(
                      tradeId: widget.tradeId,
                      content: _contentController.text,
                      rating: _rating,
                    );
                    ref
                        .read(tradeReviewProvider.notifier)
                        .createReview(reviewDto)
                        .then((_) {
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    });
                  }
                },
          child: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('등록'),
        ),
      ],
    );
  }
}
