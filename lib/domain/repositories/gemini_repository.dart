import 'dart:async';
import 'dart:convert';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

import '../../_core/constants/message.dart';
import '../../_core/utils/my_http.dart';

class GeminiRepository {
  static const _baseUrl = "$baseUrl/ai-agent/gemini";
  StreamSubscription? _streamSubscription;

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
        final eventData = event.data ?? '';

        if (eventName == 'connect') {
          controller.add({"eventName": eventName, "data": "SSE 연결 성공"});
        } else if (eventName == 'thinking') {
          controller.add({"eventName": eventName, "data": eventData});
        } else if (eventName == 'AI Response') {
          controller.add({"eventName": eventName, "data": eventData});
        } else if (eventName == 'final') {
          controller.add({"eventName": eventName, "data": eventData});
          _streamSubscription?.cancel();
          controller.close();
        } else {
          Logger().w("Unknown SSE Event: $eventName, Data: $eventData");
        }
      },
      onError: (error) {
        Logger().e("SSE Stream Error: $error");
        controller.addError({"errorMessage": "SSE 스트림 오류 발생: $error"});
        _streamSubscription?.cancel();
        controller.close();
      },
      onDone: () {
        Logger().i("SSE Stream Done");
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

    final textPart = {"text": Message.prompt};

    final requestData = {
      "contents": [
        {
          "parts": [
            ...imageParts,
            textPart,
          ]
        }
      ],
      "generation_config": {
        "thinking_config": {
          "thinking_budget": 8192,
          "include_thoughts": true,
        }
      }
    };

    final requestJson = json.encode(requestData);
    await dio.post("$_baseUrl/image/$userId/stream", data: requestJson);
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
