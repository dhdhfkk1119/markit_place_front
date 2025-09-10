import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/detail_page/widgets/detail_body.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/detail_page/widgets/detail_app_bar.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/detail_page/widgets/detail_bottom_sheet.dart';
import '../../../../../_core/constants/custom_popup.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: DetailAppBar(
        backgroundColor: _appBarColor,
        iconColor: _iconColor,
        onBack: () => Navigator.pop(context),
        onMore: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) =>
                CustomPopUp.buildAppBarPopUp(context, "조정우", "상품 이름적기", 1),
          );
        },
      ),
      body: DetailBody(scrollController: _scrollController),
      bottomSheet: DetailBottomSheet(),
    );
  }
}
