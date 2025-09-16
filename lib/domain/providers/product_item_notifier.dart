import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markit_place_front/domain/repositories/gemini_repository.dart';

class ProductItemModel {
  final List<XFile> images;
  final String title;
  final String description;
  final int price;
  final bool isLoading;
  final String errorMessage;

  ProductItemModel({
    required this.images,
    required this.title,
    required this.description,
    required this.price,
    this.isLoading = false,
    required this.errorMessage,
  });

  ProductItemModel copyWith(
      {List<XFile>? images,
      String? title,
      String? description,
      int? price,
      bool? isLoading,
      String? errorMessage}) {
    return ProductItemModel(
        images: images ?? this.images,
        title: title ?? this.title,
        description: description ?? this.description,
        price: price ?? this.price,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}

class ProductItemNotifier extends AutoDisposeNotifier<ProductItemModel> {
  StreamSubscription? _geminiSubscription;

  @override
  ProductItemModel build() {
    ref.onDispose(() {
      print("ProductItemNotifier가 dispose됩니다. 구독을 취소합니다.");
      _geminiSubscription?.cancel();
    });

    return ProductItemModel(
        images: [],
        title: "판매글의 제목을 입력해주세요.",
        description: "판매 상품의 자세한 설명을 적어주세요.",
        price: 0,
        errorMessage: "");
  }

  void uploadImages({required List<XFile> images, required bool isOn}) {
    state = state.copyWith(images: images);

    if (isOn) {
      _generateItemInfo(images: images);
    }
  }

  // 이미지 선택 취소 처리
  void removeImage(XFile image) {
    final currentImages = List<XFile>.from(state.images)..remove(image);
    state = state.copyWith(images: currentImages);
  }

  // AI Sse 구독하기
  void subscribe({required int userId}) {
    _geminiSubscription?.cancel();

    final stream = GeminiRepository().subscribe(userId: userId);

    _geminiSubscription = stream.listen(
      (response) {
        final eventName = response["eventName"];
        if (eventName == 'connect') {
          print("SSE 연결 성공!");
        } else if (eventName == 'AI Response') {
          final data = response["data"];
          print("AI 응답 도착: $data");
          _splitGeminiResponseText(data);
        }
      },
      onError: (error) {
        print("구독 중 에러 발생: $error");
        _setErrorMessage(error["errorMessage"]);
      },
      onDone: () {
        print("구독이 종료되었습니다.");
      },
    );
  }

  // 구독 취소
  void cancelSubscription() {
    _geminiSubscription?.cancel();
    state = state.copyWith(isLoading: false);
    print("SSE 구독이 사용자에 의해 취소되었습니다.");
  }

  // AI로 상품 설명 생성하기
  Future<void> _generateItemInfo({required List<XFile> images}) async {
    setLoading(true);
    await GeminiRepository().sendImagesForGemini(images: images, userId: 1);
  }

  // AI 응답 분리
  void _splitGeminiResponseText(String data) {
    if (data.isNotEmpty) {
      List<String> textList = data.split(" / ");
      String title = textList[0].replaceAll("[title]: ", "");
      String description = textList[1].replaceAll("[description]: ", "");
      state = state.copyWith(
          title: title, description: description, isLoading: false);
    }
  }

  // 에러 메시지 설정
  void _setErrorMessage(String e) {
    state = state.copyWith(errorMessage: e);
  }

  // 로딩 상태 변경
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

final productItemProvider =
    AutoDisposeNotifierProvider<ProductItemNotifier, ProductItemModel>(
        () => ProductItemNotifier());
