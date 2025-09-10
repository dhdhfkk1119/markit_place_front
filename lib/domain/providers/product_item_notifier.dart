import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markit_place_front/domain/repositories/gemini_repository.dart';

class ProductItemModel {
  final int imageCount;
  final String title;
  final String description;
  final int price;
  final bool isError;

  ProductItemModel({
    required this.imageCount,
    required this.title,
    required this.description,
    required this.price,
    this.isError = false,
  });

  ProductItemModel copyWith({
    int? imageCount,
    String? title,
    String? description,
    int? price,
    bool? isError
  }) {
    return ProductItemModel(imageCount: imageCount ?? this.imageCount, title: title ?? this.title, description: description ?? this.description, price: price ?? this.price, isError: isError ?? this.isError);
  }
}

class ProductItemNotifier extends AutoDisposeNotifier<ProductItemModel> {
  @override
  ProductItemModel build() {
    return ProductItemModel(imageCount: 0, title: "판매글의 제목을 입력해주세요.", description: "판매 상품의 자세한 설명을 적어주세요.", price: 0);
  }

  // 이미지 갯수 동기화
  void uploadImages(Function(bool) onError, {required List<XFile> images, required bool isOn}) {
    state = state.copyWith(imageCount: images.length);

    if (isOn) {
      _generateItemInfo(images: images, onError);
    }
  }

  // 이미지 선택 취소 처리
  void cancelUploadImages({required List<XFile> images}) {
    state = state.copyWith(imageCount: images.length);
  }

  // AI Sse 구독하기
  void subscribe({required int userId}) {
    GeminiRepository().subscribe(userId: userId, onDataReceived: (data) {
      if (data.isNotEmpty) {
        // 1. /로 title과 description 나누기
        List<String> textList = data.split(" / ");

        // 2. 첫번째 index로 title 값만 뽑아내기
        String title = textList[0].replaceAll("[title]: ", "");

        // 3. 두번째 index로 description 값만 뽑아내기
        String description = textList[1].replaceAll("[description]: ", "");

        // 9월 9일 17시 기준 503에러 발생 -> TODO 이후에 통신으로 받아온 데이터 처리하는 코드 리팩토링
        state = state.copyWith(title: title, description: description);
      }
    },);
  }

  // AI로 상품 설명 생성하기
  Future<void> _generateItemInfo(Function(bool) onError, {required List<XFile> images}) async {
    await GeminiRepository().sendImages(images: images, userId: 1, onError);
  }
}

final productItemProvider = AutoDisposeNotifierProvider<ProductItemNotifier, ProductItemModel>(() => ProductItemNotifier());