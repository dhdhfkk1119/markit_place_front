import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/naver_map/location_tracking_mode.dart';

class NaverMapNotifier extends Notifier<NLocationTrackingMode> {
  NaverMapController? _controller;

  @override
  NLocationTrackingMode build() {
    return NLocationTrackingMode.none;
  }

  void setMapController(NaverMapController controller) {
    _controller = controller;
  }

  // 👇 버튼 로직을 네 요구사항에 맞게 수정한 버전!
  void cycleTrackingMode() {
    if (_controller == null) return;

    final NLocationTrackingMode nextMode;

    // 현재 상태를 확인해서 다음 상태를 결정
    if (state == NLocationTrackingMode.follow) {
      // '위치 추적' 중이었다면 -> '위치 및 방향 추적'으로
      nextMode = NLocationTrackingMode.face;
    } else if (state == NLocationTrackingMode.face) {
      // '위치 및 방향 추적' 중이었다면 -> '위치 추적'으로
      nextMode = NLocationTrackingMode.follow;
    } else {
      // state == NLocationTrackingMode.None
      // '꺼져' 있었다면 -> '위치 추적'부터 시작
      nextMode = NLocationTrackingMode.follow;
    }

    _controller!.setLocationTrackingMode(nextMode);
    state = nextMode;
  }

  // 이 함수는 그대로 유지!
  void onCameraChangeByGesture() {
    if (state != NLocationTrackingMode.none) {
      state = NLocationTrackingMode.none;
    }
  }
}

final naverMapProvider =
    NotifierProvider<NaverMapNotifier, NLocationTrackingMode>(() {
  return NaverMapNotifier();
});
