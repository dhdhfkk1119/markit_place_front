import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../model/trade_model.dart';
import '../../trade_review/trade_review.dart';
import '../repository/trade_repository.dart';

final _logger = Logger();

class TradeListModelState {
  final List<TradeListModel> items;
  final int page;
  final bool hasNext;

  TradeListModelState({
    required this.items,
    required this.page,
    required this.hasNext,
  });

  TradeListModelState copyWith({
    List<TradeListModel>? items,
    int? page,
    bool? hasNext,
  }) {
    return TradeListModelState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
    );
  }
}

class TradeProvider extends AsyncNotifier<TradeListModelState> {
  final TradeRepository _repository = TradeRepository();

  @override
  Future<TradeListModelState> build() async {
    _logger.i('TradeProvider.build 호출: 초기 페이지 로드');
    return loadPage(0);
  }

  Future<TradeListModelState> loadPage(int page) async {
    _logger.i('TradeProvider.loadPage 호출: page=$page');
    try {
      final response = await _repository.tradeList(page: page);
      _logger.i('TradeProvider.loadPage: repository 응답 수신');
      final List<dynamic> content =
          response['content'] as List<dynamic>? ?? <dynamic>[];
      final List<TradeListModel> newItems =
          content.map((json) => TradeListModel.fromJson(json)).toList();
      final hasNext = !(response['last'] as bool? ?? true);
      final pageNum = response['page'] as int? ?? page;

      final currentItems = state.value?.items ?? [];
      final allItems = pageNum == 0 ? newItems : [...currentItems, ...newItems];

      final newState = TradeListModelState(
        items: allItems,
        page: pageNum,
        hasNext: hasNext,
      );
      _logger.i(
          'TradeProvider.loadPage: newState prepared items=${allItems.length} page=$pageNum hasNext=$hasNext');
      return newState;
    } catch (e, st) {
      _logger.e('TradeProvider.loadPage 오류', e, st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    _logger.i('TradeProvider.refresh 호출');
    state = const AsyncValue.loading();
    try {
      final newState = await build();
      state = AsyncValue.data(newState);
      _logger.i('TradeProvider.refresh 완료: 항목수=${newState.items.length}');
    } catch (e, st) {
      _logger.e('TradeProvider.refresh 실패', e, st);
      // 실패 시 에러 상태로 설정
      state = AsyncValue.error(e, st);
    }
  }

  // 즉시 UI에 리뷰를 반영하는 헬퍼 (낙관적 업데이트)
  void attachReviewToTrade(int tradeId, TradeReview review) {
    final current = state.value;
    if (current == null) return;
    final updatedItems = current.items.map((item) {
      if (item.tradeId == tradeId) {
        return item.copyWith(review: review, isReviewed: true);
      }
      return item;
    }).toList();
    state = AsyncValue.data(TradeListModelState(
        items: updatedItems, page: current.page, hasNext: current.hasNext));
    _logger.i('attachReviewToTrade: tradeId=$tradeId applied locally');
  }

  // 리뷰 삭제 시 로컬에서 제거 (review id 기준)
  void removeReviewById(int reviewId) {
    final current = state.value;
    if (current == null) return;
    final updatedItems = current.items.map((item) {
      if (item.review != null && item.review!.id == reviewId) {
        return item.copyWith(review: null, isReviewed: false);
      }
      return item;
    }).toList();
    state = AsyncValue.data(TradeListModelState(
        items: updatedItems, page: current.page, hasNext: current.hasNext));
    _logger.i('removeReviewById: reviewId=$reviewId applied locally');
  }

  // 단건 거래 카드 정보 갱신 (서버 최신값 반영)
  Future<void> replaceOrInsertTrade(int tradeId) async {
    try {
      final json = await _repository.getTradeById(tradeId);
      if (json.isEmpty) return;
      final updated = TradeListModel.fromJson(json);
      final current = state.value;
      if (current == null) return;
      final List<TradeListModel> items = List.of(current.items);
      final idx = items.indexWhere((e) => e.tradeId == tradeId);
      if (idx >= 0) {
        items[idx] = updated;
      } else {
        items.insert(0, updated);
      }
      state = AsyncValue.data(
        TradeListModelState(
            items: items, page: current.page, hasNext: current.hasNext),
      );
    } catch (e, st) {
      _logger.e('replaceOrInsertTrade 실패', e, st);
    }
  }
}

final tradeProvider = AsyncNotifierProvider<TradeProvider, TradeListModelState>(
    () => TradeProvider());
