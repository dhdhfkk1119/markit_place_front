import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../domain/product/providers/product_detail_notifier.dart';
import 'widgets/detail_body.dart';
import 'widgets/detail_app_bar.dart';
import 'widgets/detail_bottom_sheet.dart';
import '../../../../../_core/constants/custom_popup.dart';

class DetailPage extends ConsumerStatefulWidget {
  int productId;

  DetailPage({required this.productId, super.key});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  final ScrollController _scrollController = ScrollController();
  Color _appBarColor = Colors.transparent;
  Color _iconColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    double offset = _scrollController.offset.clamp(0, 100);
    double t = offset / 100;

    setState(() {
      _appBarColor = Color.lerp(Colors.transparent, Colors.white, t)!;
      _iconColor = Color.lerp(Colors.white, Colors.black, t)!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productDetailProvider(widget.productId));

    return productState.when(
      data: (productDetail) {
        final product = productDetail.productList;
        final sellerId = productDetail.sellerId;
        final itemId = product.id;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: DetailAppBar(
            productId: widget.productId,
            backgroundColor: _appBarColor,
            iconColor: _iconColor,
            onBack: () => Navigator.pop(context),
            onMore: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return CustomPopUp.buildAppBarPopUp(
                    context,
                    "${product.title}",
                    "${product.content}",
                    itemId,
                    ref: ref,
                  );
                },
              );
            },
          ),
          body: DetailBody(
            scrollController: _scrollController,
            productId: widget.productId,
          ),
          bottomSheet: DetailBottomSheet(
            receiverId: sellerId,
            itemId: itemId,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('상품 정보를 불러오는 중 오류 발생: $err')),
    );
  }
}
