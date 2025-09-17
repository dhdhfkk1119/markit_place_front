import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

import '../../_core/utils/my_http.dart';

class GeminiRepository {
  static const _baseUrl = "$baseUrl/ai-agent/gemini";
  StreamSubscription? _streamSubscription;
  String Function(String response)? onData;

  static Map<String, dynamic> response = {};

  Stream<Map<String, dynamic>> subscribe({required int userId}) {
    final controller = StreamController<Map<String, dynamic>>();

    _streamSubscription?.cancel();

    final url = "$_baseUrl/subscribe/$userId";

    _streamSubscription = SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: url,
      header: {"Accept": "text/event-stream"},
    ).listen(
      (event) {
        final eventName = event.event ?? '';

        if (eventName == 'connect') {
          controller.add(
              {"eventName": eventName, "errorMessage": null, "data": null});
        } else if (eventName == 'AI Response') {
          if (event.data!.isNotEmpty) {
            controller.add({
              "eventName": eventName,
              "errorMessage": null,
              "data": event.data
            });
            _streamSubscription?.cancel();
            controller.close();
          }
        }
      },
      onError: (error) {
        controller.addError({"errorMessage": "SSE 스트림 오류 발생: $error"});
        _streamSubscription?.cancel();
        controller.close();
      },
      onDone: () {
        if (!controller.isClosed) {
          controller.close();
        }
      },
    );

    return controller.stream;
  }

  Future<void> sendImagesForGemini(
      {required List<XFile> images, required int userId}) async {
    final List<Map<String, dynamic>> base64Images =
        await _convertBase64Images(images);

    final List<Map<String, dynamic>> imageParts = base64Images.map((imgMap) {
      return {
        "inline_data": {
          "mime_type": imgMap["mimeType"],
          "data": imgMap["imageData"]
        }
      };
    }).toList();

    final textPart = {
      "text":
          "너는 상품의 장점을 매력적으로 어필하는 전문 마케터야. 제시된 이미지들을 분석해서, 고객이 이 상품을 구매했을 때 얻게 될 경험이나 혜택을 중심으로 설득력 있는 판매글을 작성해 줘. 감성적이면서도 신뢰감을 주는 어조를 사용하고, 이모티콘은 문장의 의미를 해치지 않는 선에서 상징적인 의미로만 사용해. 형식은 반드시 [name]: name / [description]: description 이런 식으로 만들어줘야 해. 절대로 형식을 벗어나지 말아줘."
    };

    final requestData = {
      "contents": [
        {
          "parts": [
            ...imageParts,
            textPart,
          ]
        }
      ]
    };

    final requestJson = json.encode(requestData);
    await dio.post("$_baseUrl/image/$userId", data: requestJson);
  }

  Future<List<Map<String, dynamic>>> _convertBase64Images(
      List<XFile> images) async {
    try {
      final List<Map<String, dynamic>> base64Images = [];
      for (XFile image in images) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        final extension = path.extension(image.path).toLowerCase();

        String mimeType = "image/jpeg";
        if (extension == ".png") {
          mimeType = "image/png";
        } else if (extension == ".gif") {
          mimeType = "image/gif";
        }

        final Map<String, dynamic> imageData = {
          "mimeType": mimeType,
          "imageData": base64String
        };

        base64Images.add(imageData);
      }
      return base64Images;
    } catch (e) {
      return [];
    }
  }
}
