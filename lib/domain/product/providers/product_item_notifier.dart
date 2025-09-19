import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markit_place_front/domain/repositories/gemini_repository.dart';

class ProductItemModel {
  final List<XFile> images;
  final String name;
  final String description;
  final int price;
  final bool isOn;
  final bool isLoading;
  final String errorMessage;
  final String thinkingMessage;
  final String streamingText;

  ProductItemModel({
    required this.images,
    required this.name,
    required this.description,
    required this.price,
    this.isOn = false,
    this.isLoading = false,
    required this.errorMessage,
    this.thinkingMessage = "",
    this.streamingText = "",
  });

  ProductItemModel copyWith({
    List<XFile>? images,
    String? name,
    String? description,
    int? price,
    bool? isOn,
    bool? isLoading,
    String? errorMessage,
    String? thinkingMessage,
    String? streamingText,
  }) {
    return ProductItemModel(
      images: images ?? this.images,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      isOn: isOn ?? this.isOn,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      thinkingMessage: thinkingMessage ?? this.thinkingMessage,
      streamingText: streamingText ?? this.streamingText,
    );
  }
}

class ProductItemNotifier extends AutoDisposeNotifier<ProductItemModel> {
  StreamSubscription? _geminiSubscription;
  String _accumulatedResponse = "";

  @override
  ProductItemModel build() {
    ref.onDispose(() {
      _geminiSubscription?.cancel();
    });
    return ProductItemModel(
        images: [], name: "", description: "", price: 0, errorMessage: "");
  }

  void updateDescription(String? newDescription) {
    state = state.copyWith(description: newDescription);
  }

  void updateName(String? newtitle) {
    state = state.copyWith(name: newtitle);
  }

  void updatePrice(int? newPrice) {
    state = state.copyWith(price: newPrice);
  }

  void uploadImages({required List<XFile> images, required bool isOn}) {
    // 새 이미지가 올라오면 기존 AI 분석 내용은 초기화
    state = state.copyWith(
        images: images, name: "", description: "", streamingText: "");
    if (isOn) {
      state = state.copyWith(
          isLoading: true, thinkingMessage: "서버에게 요청을 보내고 있습니다...");
      _generateItemInfo(images: images);
    }
  }

  void removeImage(XFile image) {
    final currentImages = List<XFile>.from(state.images)..remove(image);
    state = state.copyWith(images: currentImages);
  }

  // --- 여기가 최종 수정된 버전! ---
  void subscribe({required int userId}) {
    _geminiSubscription?.cancel();
    _accumulatedResponse = "";

    final stream = GeminiRepository().subscribe(userId: userId);

    _geminiSubscription = stream.listen(
      (response) {
        final eventName = response["eventName"];
        final data = response["data"] ?? "";

        switch (eventName) {
          case 'thinking':
            print(data);
            state = state.copyWith(isLoading: true, thinkingMessage: data);
            break;

          case 'AI Response':
            // 1단계: \\n을 \n으로 먼저 바꿔준다.
            String processedChunk = data.replaceAll('\\n', '\n');

            // 2단계: 외톨이 줄바꿈(\n)만 찾아서 공백(' ')으로 바꿔준다.
            //       이렇게 하면 단어가 서로 붙지 않고 예쁘게 떨어져.
            final lonelyNewlineRegex = RegExp(r'(?<!\n)\n(?!\n)');
            String cleanedChunk =
                processedChunk.replaceAll(lonelyNewlineRegex, ' ');

            _accumulatedResponse += cleanedChunk;

            state = state.copyWith(
                streamingText: _accumulatedResponse, isLoading: true);
            break;

          case 'final':
            // 1. 불필요한 앞뒤 공백과 여러 개의 줄바꿈을 정리한다.
            //    \s*는 공백, \n은 줄바꿈을 의미해. 이걸 찾아서 깔끔하게 문단 나누기(\n\n)로 바꿔줘.
            String cleanedText = _accumulatedResponse.trim();

            // 2. 정리된 최종 텍스트를 파싱한다.
            _splitGeminiResponseText(cleanedText);

            // 3. 모든 로딩 상태를 최종적으로 해제한다.
            state = state.copyWith(isLoading: false, thinkingMessage: "");
            break;
        }
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error["errorMessage"],
          thinkingMessage: "",
        );
      },
      onDone: () {
        if (state.isLoading) {
          // 로딩 중에 끝났을 경우를 대비
          String cleanedText = _accumulatedResponse.trim();
          _splitGeminiResponseText(cleanedText);
          state = state.copyWith(isLoading: false, thinkingMessage: "");
        }
      },
    );
  }

  void cancelSubscription() {
    _geminiSubscription?.cancel();
    state = state.copyWith(isLoading: false, thinkingMessage: "");
  }

  Future<void> _generateItemInfo({required List<XFile> images}) async {
    await GeminiRepository().sendImagesForGemini(images: images, userId: 1);
  }

  void _splitGeminiResponseText(String data) {
    if (data.isEmpty) return;

    RegExp regExp = RegExp(r"\[name\]:\s*(.*?)\s*/\s*\[description\]:\s*(.*)",
        dotAll: true);
    if (!data.contains("/")) {
      regExp =
          RegExp(r"\[name\]:\s*(.*?)\s*\[description\]:\s*(.*)", dotAll: true);
    }

    final match = regExp.firstMatch(data);

    if (match != null && match.groupCount >= 2) {
      final name = match.group(1)?.trim() ?? state.name;
      final description = match.group(2)?.trim() ?? state.description;
      // 파싱된 최종 결과를 name과 description에 업데이트
      state = state.copyWith(name: name, description: description);
    }
  }

  void setOn(bool isOn) {
    state = state.copyWith(isOn: isOn);
  }

  void setDescription({required String name, required String description}) {
    state = state.copyWith(name: name, description: description);
  }
}

final productItemProvider =
    AutoDisposeNotifierProvider<ProductItemNotifier, ProductItemModel>(
        () => ProductItemNotifier());
