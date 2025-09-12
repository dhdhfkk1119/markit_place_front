import 'dart:async';
import 'dart:convert';

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

  void subscribe(
      {required int userId,
      required void Function(String data) onDataReceived}) {
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
          // TODO 구독 성공시 로직 처리
        } else if (eventName == 'AI Response') {
          if (event.data!.isNotEmpty) {
            _streamSubscription?.cancel();
            onDataReceived(event.data ?? '');
          }
        }
      },
      onError: (error) {
        _streamSubscription?.cancel();
      },
    );
  }

  Future<Map<String, dynamic>> sendImagesForGemini(Function(bool) onError,
      {required List<XFile> images, required int userId}) async {
    try {
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
            "이미지를 종합적으로 분석하고, 적절한 상품 설명을 작성해주면 돼. 이때 형식은 [title]: title / [description]: description 이런 식으로 만들어줘야 해. 절대로 형식을 벗어나지 말아줘."
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
      final response =
          await dio.post("$_baseUrl/image/$userId", data: requestJson);

      if (response.statusCode != 200) {
        throw Exception("통신 실패.....");
      }
      return {};
    } on Exception catch (e) {
      onError(true);
      return {};
    }
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
