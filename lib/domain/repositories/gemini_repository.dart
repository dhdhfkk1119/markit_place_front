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

  // subscribe 메서드는 이제 서버가 보내주는 3가지 이벤트를 모두 처리해.
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

        // --- 여기가 핵심! 서버와 약속한 모든 이벤트를 처리 ---
        if (eventName == 'connect') {
          // 연결 성공 이벤트
          controller.add({"eventName": eventName, "data": "SSE 연결 성공"});
        } else if (eventName == 'thinking') {
          // 1. AI가 생각 중이라는 이벤트
          controller.add({"eventName": eventName, "data": eventData});
        } else if (eventName == 'AI Response') {
          // 2. AI가 답변을 보내주는 이벤트
          controller.add({"eventName": eventName, "data": eventData});
        } else if (eventName == 'final') {
          // 3. 모든 스트림이 끝났다는 이벤트
          controller.add({"eventName": eventName, "data": eventData});
          // 'final' 신호를 받으면 스트림을 안전하게 종료한다.
          _streamSubscription?.cancel();
          controller.close();
        } else {
          // 예상치 못한 이벤트 로그 남기기 (디버깅용)
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

  // sendImagesForGemini 메서드는 요청 데이터에 '사고 기능 켜기' 옵션을 추가해.
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
          "너는 상품의 장점을 매력적으로 어필하는 전문 마케터야. 제시된 이미지들을 분석해서, 고객이 이 상품을 구매했을 때 얻게 될 경험이나 혜택을 중심으로 설득력 있는 판매글을 작성해 줘. 감성적이면서도 신뢰감을 주는 어조를 사용하고, 이모티콘은 문장의 의미를 해치지 않는 선에서 상징적인 의미로만 사용해. 형식은 반드시 [name]: name / [description]: description 이런 식으로 만들어줘야 해. 절대로 형식을 벗어나지 말아줘. 특히, description 부분은 문장이 중간에 끊기지 않게 완전한 문장으로 만들고, 문단은 줄바꿈 두 번(\\n\\n)으로 구분해줘."
    };

    // --- 요청 데이터 구조 수정 ---
    final requestData = {
      "contents": [
        {
          "parts": [
            ...imageParts,
            textPart,
          ]
        }
      ],
      // '사고 기능'을 켜달라고 서버에 요청하는 부분!
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

  // _convertBase64Images 메서드는 변경 없음
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
