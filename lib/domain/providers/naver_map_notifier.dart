import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NaverMapNotifier extends Notifier<NLocationTrackingMode> {
  NaverMapController? _controller;

  @override
  NLocationTrackingMode build() {
    return NLocationTrackingMode.none;
  }

  void setMapController(NaverMapController controller) {
    _controller = controller;
  }

  void cycleTrackingMode() {
    if (_controller == null) return;

    final NLocationTrackingMode nextMode;

    if (state == NLocationTrackingMode.follow) {
      nextMode = NLocationTrackingMode.face;
    } else if (state == NLocationTrackingMode.face) {
      nextMode = NLocationTrackingMode.follow;
    } else {
      nextMode = NLocationTrackingMode.follow;
    }

    _controller!.setLocationTrackingMode(nextMode);
    state = nextMode;
  }

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
