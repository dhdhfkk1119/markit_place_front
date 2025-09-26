import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../domain/trade/model/trade_model.dart';
import '../../../../../domain/trade/provider/trade_provider.dart';
import '../../../../../domain/trade_review/trade_review.dart';
import '../../../../../domain/trade_review/trade_review_provider.dart';
import '../../../../../domain/trade_review/trade_review_dto.dart';

// 구매내역 화면: 사용자의 구매 내역을 리스트로 보여줌
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
    // `loadNextPage` 메소드가 `TradeProvider`에서 제거되었으므로 리스너를 제거합니다.
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 구매내역 상태 구독
    final state = ref.watch(tradeProvider);

    // 리뷰 처리 결과에 따라 스낵바 표시 (개별 카드 갱신으로 전체 새로고침 제거)
    ref.listen<AsyncValue<TradeReview?>>(tradeReviewProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰 처리 중 오류: ${next.error}')),
        );
      } else if (next.hasValue && next.value != null) {
        // 리뷰 작업이 완료된 후에 출력되는 메시지는 표시하지 않음
        // 작업 유형별 메시지는 작업 시작 시점에 표시됨
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
                  child: _buildPurchaseItem(
                    model: item,
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
    final imageBytes = base64ToBytes(model.itemThumbnail);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(128, 128, 128, 0.2),
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
    final review = model.review;
    final bool hasReview = review != null;
    final bool isSubmitting = ref.watch(tradeReviewProvider).isLoading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (hasReview) ...[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                review.content,
                style: const TextStyle(color: Colors.black, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 18),
            tooltip: '리뷰 삭제',
            onPressed: isSubmitting
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('리뷰 삭제'),
                        content: const Text('리뷰를 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('취소')),
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('삭제')),
                        ],
                      ),
                    );
                    if (confirmed != true) return;

                    // 삭제 시작 시 메시지 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('삭제 중...'),
                          duration: Duration(seconds: 1)),
                    );

                    await ref.read(tradeReviewProvider.notifier).deleteReview(
                        tradeId: model.tradeId, reviewId: review.id);

                    // 삭제 완료 메시지
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('리뷰가 삭제됐습니다')),
                      );
                    }
                  },
          ),
          TextButton(
            onPressed: isSubmitting
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (context) => _ReviewFormDialog(
                        tradeId: model.tradeId,
                        reviewId: review.id,
                        initialContent: review.content,
                        initialRating: review.rating,
                        actionType: 'update',
                      ),
                    );
                  },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('리뷰 수정',
                style: TextStyle(color: Colors.black, fontSize: 12)),
          ),
        ] else ...[
          TextButton(
            onPressed: isSubmitting
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (context) => _ReviewFormDialog(
                        tradeId: model.tradeId,
                        actionType: 'create',
                      ),
                    );
                  },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('리뷰 작성',
                style: TextStyle(color: Colors.black, fontSize: 12)),
          ),
        ],
      ],
    );
  }
}

class _ReviewFormDialog extends ConsumerStatefulWidget {
  final int tradeId;
  final int? reviewId;
  final String? initialContent;
  final int? initialRating;
  final String actionType; // 'create' 또는 'update' 작업 유형

  const _ReviewFormDialog({
    required this.tradeId,
    this.reviewId,
    this.initialContent,
    this.initialRating,
    required this.actionType,
  });

  @override
  ConsumerState<_ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends ConsumerState<_ReviewFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;
  late int _rating;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.reviewId == null) {
      _contentController =
          TextEditingController(text: widget.initialContent ?? '정말 친절하세요');
      _rating = widget.initialRating ?? 5;
    } else {
      _contentController =
          TextEditingController(text: widget.initialContent ?? '');
      _rating = widget.initialRating ?? 0;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting =
        ref.watch(tradeReviewProvider).isLoading || _isSubmitting;

    return AlertDialog(
      title: Text(widget.actionType == 'update' ? '리뷰 수정' : '리뷰 작성'),
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
                    onPressed: isSubmitting
                        ? null
                        : () {
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
                enabled: !isSubmitting,
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
              : () async {
                  if (_rating == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('별점을 선택해주세요.')),
                    );
                    return;
                  }
                  if (_formKey.currentState!.validate()) {
                    // 제출 시작 상태로 변경
                    setState(() {
                      _isSubmitting = true;
                    });

                    final reviewDto = TradeReviewRequestDto(
                      tradeId: widget.tradeId,
                      content: _contentController.text,
                      rating: _rating,
                    );

                    // 작업 시작 메시지 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.actionType == 'update'
                            ? '수정 중...'
                            : '작성 중...'),
                        duration: const Duration(seconds: 1),
                      ),
                    );

                    try {
                      if (widget.actionType == 'update') {
                        await ref
                            .read(tradeReviewProvider.notifier)
                            .updateReview(widget.reviewId!, reviewDto);

                        // 완료 메시지
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('리뷰가 수정됐습니다')),
                          );
                        }
                      } else {
                        await ref
                            .read(tradeReviewProvider.notifier)
                            .createReview(reviewDto);

                        // 완료 메시지
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('리뷰가 등록됐습니다')),
                          );
                        }
                      }

                      if (mounted) Navigator.of(context).pop();
                    } catch (e) {
                      setState(() {
                        _isSubmitting = false;
                      });
                      if (mounted) Navigator.of(context).pop();
                    }
                  }
                },
          child: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.actionType == 'update' ? '수정' : '등록'),
        ),
      ],
    );
  }
}
