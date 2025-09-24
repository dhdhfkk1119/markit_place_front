import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/qna_list_model.dart';
import '../repository/qna_list_repository.dart';

class QnaListState {
  final List<QnaListModel> items;
  final int page;
  final bool hasNext;

  QnaListState({
    required this.items,
    required this.page,
    required this.hasNext,
  });

  QnaListState copyWith({
    List<QnaListModel>? items,
    int? page,
    bool? hasNext,
  }) {
    return QnaListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
    );
  }
}

class QnaListNotifier extends AsyncNotifier<QnaListState> {
  final QnaListRepository _repository = QnaListRepository();

  @override
  Future<QnaListState> build() async {
    return loadPage(0); // 초기 페이지 로딩
  }

  Future<QnaListState> loadPage(int page) async {
    final response = await _repository.qnaList(page: page);
    final List<dynamic> content = response['content'];
    final List<QnaListModel> newItems =
        content.map((json) => QnaListModel.fromJson(json)).toList();

    final hasNext = !response['last']; // 마지막 페이지 여부
    final currentItems = state.value?.items ?? [];
    final allItems = page == 0 ? newItems : [...currentItems, ...newItems];

    final newState = QnaListState(
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

final qnaListProvider = AsyncNotifierProvider<QnaListNotifier, QnaListState>(
    () => QnaListNotifier());
