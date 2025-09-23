import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/notice_list_model.dart';
import '../repository/notice_list_repository.dart';

class NoticeListState {
  final List<NoticeListModel> items;
  final int page;
  final bool hasNext;

  NoticeListState({
    required this.items,
    required this.page,
    required this.hasNext,
  });

  NoticeListState copyWith({
    List<NoticeListModel>? items,
    int? page,
    bool? hasNext,
  }) {
    return NoticeListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
    );
  }
}

class NoticeListNotifier extends AsyncNotifier<NoticeListState> {
  final NoticeListRepository _repository = NoticeListRepository();

  @override
  Future<NoticeListState> build() async {
    return loadPage(0); // 초기 페이지 로딩
  }

  Future<NoticeListState> loadPage(int page) async {
    final response = await _repository.noticeList(page: page);
    final List<dynamic> content = response['content'];
    final List<NoticeListModel> newItems =
        content.map((json) => NoticeListModel.fromJson(json)).toList();

    final hasNext = !response['last']; // 마지막 페이지 여부
    final currentItems = state.value?.items ?? [];
    final allItems = page == 0 ? newItems : [...currentItems, ...newItems];

    final newState = NoticeListState(
      items: allItems,
      page: page,
      hasNext: hasNext,
    );

    state = AsyncValue.data(newState);
    return newState;
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => loadPage(0));
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasNext) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith());

    final result =
        await AsyncValue.guard(() => loadPage(currentState.page + 1));
    state = result.when(
      data: (data) => AsyncValue.data(data),
      loading: () => AsyncValue.data(currentState),
      error: (err, stack) => AsyncValue.error(err, stack),
    );
  }
}

final noticeListProvider =
    AsyncNotifierProvider<NoticeListNotifier, NoticeListState>(
        () => NoticeListNotifier());
