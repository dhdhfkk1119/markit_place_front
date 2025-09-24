import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../domain/notice/model/notice_list_model.dart';
import '../../../../../domain/notice/provider/notice_list_notifier.dart'; // CustomWidget import

class NoticeScreen extends ConsumerStatefulWidget {
  const NoticeScreen({super.key});

  @override
  ConsumerState<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends ConsumerState<NoticeScreen> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(
      () {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100) {
          ref.read(noticeListProvider.notifier).loadNextPage();
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
    final state = ref.watch(noticeListProvider);
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
            '공지사항 메인화면',
            color: Colors.black,
          ),
          centerTitle: true,
          actions: [
            CustomWidget.buildIcon(
              const Icon(Icons.refresh, color: Colors.black),
              onPressed: () async {
                await ref.read(noticeListProvider.notifier).refresh();
              },
            ),
          ],
        ),
        body: state.when(
          data: (data) {
            if (data.items.isEmpty) {
              return const Center(
                child: Text(
                  '공지사항이 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(noticeListProvider.notifier).refresh();
              },
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: data.items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildNoticeItem(
                            model: data.items[index],
                          ),
                        ],
                      ),
                    );
                  }),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text('에러 발생: $err'),
          ),
        ));
  }

  Widget _buildNoticeItem({required NoticeListModel model}) {
    if (model == null) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomWidget.buildTitle(
                model.title,
                size: 14,
                weight: FontWeight.w700,
              ),
              const SizedBox(width: 8),
              CustomWidget.buildTitle(
                model.content,
                size: 14,
                weight: FontWeight.normal,
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomWidget.buildTitle(
            model.createdAt,
            size: 12,
            color: Colors.grey[600],
            weight: FontWeight.w200,
          ),
        ],
      ),
    );
  }
}
