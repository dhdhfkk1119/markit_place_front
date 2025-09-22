import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';

class NaverMapNotifier extends Notifier<NLocationTrackingMode> {
  NaverMapController? _controller;
  LocationData? _currentPosition;
  bool _isCyclingMode = false;

  @override
  NLocationTrackingMode build() {
    ref.listen<AsyncValue<LocationData>>(locationStreamProvider, (_, next) {
      if (next.hasValue) {
        _currentPosition = next.value;
      }
    });
    return NLocationTrackingMode.none;
  }

  void setMapController(NaverMapController controller) {
    _controller = controller;
  }

  void cycleTrackingMode() async {
    if (_controller == null || _isCyclingMode) return;

    _isCyclingMode = true;
    final NLocationTrackingMode nextMode;

    if (state != NLocationTrackingMode.follow) {
      nextMode = NLocationTrackingMode.follow;
      if (_currentPosition != null) {
        final target =
            NLatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
        final cameraUpdate = NCameraUpdate.withParams(target: target, zoom: 15);
        await _controller!.updateCamera(cameraUpdate);
      }
    } else {
      nextMode = NLocationTrackingMode.face;
    }

    _controller!.setLocationTrackingMode(nextMode);
    state = nextMode;
    _isCyclingMode = false;
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

final locationStreamProvider =
    StreamProvider.autoDispose<LocationData>((ref) async* {
  final location = Location();

  var serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  var permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  yield* location.onLocationChanged;
});
