import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/providers/naver_map_notifier.dart';

class NearPage extends ConsumerStatefulWidget {
  const NearPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NearPageState();
}

class _NearPageState extends ConsumerState<NearPage> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    final currentTrackingMode = ref.watch(naverMapProvider);

    final IconData fabIcon;
    switch (currentTrackingMode) {
      case NLocationTrackingMode.face:
        fabIcon = Icons.explore;
        break;
      default:
        fabIcon = Icons.my_location;
    }

    final Color fabColor = (currentTrackingMode == NLocationTrackingMode.none)
        ? Colors.black54
        : Colors.blue;

    return Scaffold(
      body: NaverMap(
        options: const NaverMapViewOptions(
          mapType: NMapType.basic,
        ),
        onMapReady: (controller) {
          ref.read(naverMapProvider.notifier).setMapController(controller);
          ref.read(naverMapProvider.notifier).cycleTrackingMode();
        },
        onCameraChange: (reason, animated) {
          if (reason == NCameraUpdateReason.gesture) {
            ref.read(naverMapProvider.notifier).onCameraChangeByGesture();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.white,
        onPressed: () {
          ref.read(naverMapProvider.notifier).cycleTrackingMode();
        },
        child: Icon(
          fabIcon,
          color: fabColor,
        ),
      ),
    );
  }
}
