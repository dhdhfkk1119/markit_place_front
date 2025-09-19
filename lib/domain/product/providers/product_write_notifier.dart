// domain/product/providers/product_write_notifier.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../dtos/product_write_dto.dart';
import 'product_list_notifier.dart';
import '../repository/product_write_repository.dart';
import 'product_item_notifier.dart'; // AI Notifier
import 'product_category_notifier.dart'; // 카테고리 Notifier

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
    required List<XFile> images,
    required int memberId, // 사용자 ID도 인자로 받음
  }) async {
    state = const AsyncLoading(); // 로딩 상태 시작

    try {
      // 1. DTO 생성: UI에서 받은 인자를 사용하여 DTO를 만듭니다.
      final writeDto = ProductWriteDto(
        itemCategoryId: selectedCategoryId,
        title: title,
        content: content,
        price: price,
      );

      // 2. 이미지 파일 리스트를 Base64 문자열 리스트로 변환
      final base64Images = await _convertImagesToBase64(images);

      // 3. 리포지토리 메서드 호출
      await _repository.productWrite(writeDto, memberId, base64Images);

      ref.read(productListProvider.notifier).getProductList();

      state = const AsyncData(null); // 성공
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace); // 실패
    }
  }

  // XFile 리스트를 Base64 문자열 리스트로 변환하는 헬퍼 메서드
  Future<List<String>> _convertImagesToBase64(List<XFile> images) async {
    List<String> base64List = [];
    for (XFile image in images) {
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      // Dart의 'dart:convert' 라이브러리를 사용하여 Base64로 인코딩
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
