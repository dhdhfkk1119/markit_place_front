import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/widgets/product_list_item.dart';
import 'package:markit_place_front/domain/product/providers/product_list_notifier.dart'; // Import your Notifier Provider

import '../../../../../../_core/constants/custom_widget.dart';

class ProductListView extends ConsumerWidget {
  // Change to ConsumerWidget
  final bool isFilterVisible;

  const ProductListView({super.key, required this.isFilterVisible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef ref
    final notifier = ref.watch(productListProvider); // Watch the provider
    final productList = notifier.productList;

    // Handle loading and error states
    if (notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifier.errorMessage != null) {
      return Center(child: Text('Error: ${notifier.errorMessage}'));
    }

    return ListView.separated(
      itemCount: productList.length, // Use the actual data length
      itemBuilder: (context, index) {
        final product = productList[index]; // Get the data for the current item
        return Padding(
          padding: const EdgeInsets.all(8.0),
          // Pass the product data and isFilterVisible to the item widget
          child: ProductListItem(product, isFilterVisible),
        );
      },
      separatorBuilder: (_, __) => const Divider(
        height: 32,
        thickness: 1,
        color: Colors.grey,
      ),
    );
  }
}
