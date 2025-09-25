import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product/providers/product_list_notifier.dart';
import '../repository/trade_repository.dart';
import 'trade_provider.dart';

class BuyItemState {
  final bool isLoading;
  final String? error;

  BuyItemState({this.isLoading = false, this.error});

  BuyItemState copyWith({bool? isLoading, String? error}) {
    return BuyItemState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TradeBuyProvider extends Notifier<BuyItemState> {
  final TradeRepository _repository = TradeRepository();

  @override
  BuyItemState build() {
    return BuyItemState(); // 초기 상태
  }

  Future<void> buyItem(int productId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.buyItem(productId: productId);
      await ref.read(tradeProvider.notifier).refresh();
      await ref.read(productListProvider.notifier).refreshProductList();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final buyItemProvider = NotifierProvider<TradeBuyProvider, BuyItemState>(
  () => TradeBuyProvider(),
);
