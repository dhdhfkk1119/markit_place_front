import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../dtos/product_write_dto.dart';
import 'product_list_notifier.dart';
import '../repository/product_write_repository.dart';

// 상품 등록 상태를 관리하는 Notifier
class ProductWriteNotifier extends AutoDisposeAsyncNotifier<void> {
  final _repository = ProductWriteRepository();

  @override
  Future<void> build() async {}

  Future<void> writeProduct({
    required int selectedCategoryId,
    required String title,
    required String content,
    required int price,
    List<XFile>? images,
    required int memberAddressId,
    String? tradeLocation,
  }) async {
    state = const AsyncLoading();

    try {
      final writeDto = ProductWriteDto(
        itemCategoryId: selectedCategoryId,
        title: title,
        content: content,
        price: price,
        tradeLocation: tradeLocation,
      );

      final base64Images = await _convertImagesToBase64(images ?? []);

      await _repository.productWrite(writeDto, memberAddressId, base64Images);

      ref.read(productListProvider.notifier).getProductList();
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<List<String>> _convertImagesToBase64(List<XFile> images) async {
    List<String> base64List = [];
    for (XFile image in images) {
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      String base64String = base64Encode(bytes);
      base64List.add(base64String);
    }
    return base64List;
  }
}

// Provider 정의
final productWriteProvider =
    AutoDisposeAsyncNotifierProvider<ProductWriteNotifier, void>(
        () => ProductWriteNotifier());
