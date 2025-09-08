import 'dart:async';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

import '../../_core/utils/my_http.dart';

void main() {
  GeminiRepository().subscribe(userId: 1);
}

class GeminiRepository {
  static final _baseUrl = "$baseUrl/ai-agent/gemini";
  StreamSubscription? _streamSubscription;

  Future<dynamic> subscribe({required int userId}) async {
    _streamSubscription = SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: "$_baseUrl/subscribe/$userId",
        header: {"Accept": "text/event-stream"}).listen(
      (event) {
        final eventName = event.event;

        if (eventName == "connect") {
          print("연결됨");
        } else if (eventName == "AI Response") {
          // TODO 응답시 해야할 코드
        }
        else if (eventName == "error") {
          throw Exception(event.data);
        }
        else if (eventName == "end") {
          // TODO 응답 종료시 해야할 코드
        }
      },
      onError: (error) {
        // 클라이언트에서 catch된 오류
        throw Exception(error);
      },
    );
  }
}
