import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../domain/qna/model/qna_list_model.dart';
import '../../../../../domain/qna/provider/qna_list_notifier.dart';

class QnaScreen extends ConsumerStatefulWidget {
  const QnaScreen({super.key});

  @override
  ConsumerState<QnaScreen> createState() => _QnaScreenState();
}

class _QnaScreenState extends ConsumerState<QnaScreen> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(
      () {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100) {
          ref.read(qnaListProvider.notifier).loadNextPage();
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qnaListProvider);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: CustomWidget.buildIcon(
            const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: CustomWidget.buildTitle(
            '고객 센터',
            color: Colors.black,
          ),
          centerTitle: true,
          actions: [
            CustomWidget.buildIcon(
              const Icon(Icons.refresh, color: Colors.black),
              onPressed: () async {
                await ref.read(qnaListProvider.notifier).refresh();
              },
            ),
          ],
        ),
        body: state.when(
            data: (data) {
              if (data.items.isEmpty) {
                return const Center(
                  child: Text(
                    '질문 내역이 없습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await ref.read(qnaListProvider.notifier).refresh();
                },
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: data.items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildQnaItem(model: data.items[index]),
                          ],
                        ),
                      );
                    }),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
                  child: Text('에러 발생: $err'),
                )));
  }

  Widget _buildQnaItem({required QnaListModel model}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.buildTitle(
                  '[문의]',
                  size: 14,
                  weight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  model.question,
                  size: 16,
                  weight: FontWeight.normal,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  model.createdAt == null ? '----/--/--' : model.createdAt,
                  size: 12,
                  color: Colors.grey[600],
                  weight: FontWeight.normal,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}
