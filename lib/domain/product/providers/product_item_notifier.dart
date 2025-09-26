import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../repositories/gemini_repository.dart';

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
  final List<String> networkBase64Images;

  ProductItemModel(
      {required this.images,
      required this.name,
      required this.description,
      required this.price,
      this.isOn = false,
      this.isLoading = false,
      required this.errorMessage,
      this.thinkingMessage = "",
      this.streamingText = "",
      required this.networkBase64Images});

  ProductItemModel copyWith(
      {List<XFile>? images,
      String? name,
      String? description,
      int? price,
      bool? isOn,
      bool? isLoading,
      String? errorMessage,
      String? thinkingMessage,
      String? streamingText,
      List<String>? networkBase64Images}) {
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
      networkBase64Images: networkBase64Images ?? this.networkBase64Images,
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
        images: [],
        networkBase64Images: [],
        name: "",
        description: "",
        price: 0,
        errorMessage: "");
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

  void setInitialNetworkImages(List<String> base64Images) {
    state = state.copyWith(networkBase64Images: base64Images);
  }

  void uploadImages({required List<XFile> images, required bool isOn}) {
    state = state.copyWith(
        images: images, name: "", description: "", streamingText: "");
    if (isOn) {
      state = state.copyWith(
          isLoading: true, thinkingMessage: "서버에게 요청을 보내고 있습니다...");
      _generateItemInfo(images: images);
    }
  }

  void removeImage({XFile? image, String? base64String}) {
    print("현재 로컬 이미지 수 : ${state.images.length}");
    print("현재 서버 이미지 수 : ${state.networkBase64Images.length}");

    if (image != null) {
      // 1. 로컬 이미지(XFile) 삭제
      final currentImages = List<XFile>.from(state.images)
        ..removeWhere((x) => x.path == image.path);
      state = state.copyWith(images: currentImages);
      print("-> 로컬 이미지 삭제 완료");
    } else if (base64String != null && base64String.isNotEmpty) {
      // 2. 서버 이미지(Base64 String) 삭제
      final currentNetworkImages = List<String>.from(state.networkBase64Images)
        ..removeWhere((base64) => base64 == base64String);

      state = state.copyWith(networkBase64Images: currentNetworkImages);
      print("-> 서버 이미지 삭제 완료");
    }
  }

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
            String processedChunk = data.replaceAll('\\n', '\n');
            final lonelyNewlineRegex = RegExp(r'(?<!\n)\n(?!\n)');
            String cleanedChunk =
                processedChunk.replaceAll(lonelyNewlineRegex, ' ');

            _accumulatedResponse += cleanedChunk;

            state = state.copyWith(
                streamingText: _accumulatedResponse, isLoading: true);
            break;

          case 'error':
            state = state.copyWith(
              isLoading: false,
              errorMessage: data,
              thinkingMessage: "",
            );
            break;

          case 'final':
            String cleanedText = _accumulatedResponse.trim();
            _splitGeminiResponseText(cleanedText);
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
