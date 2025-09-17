import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/naver_map/location_tracking_mode.dart';
import '../../../../domain/providers/naver_map_notifier.dart';

class NearPage extends ConsumerWidget {
  const NearPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        onMapReady: (controller) {
          ref.read(naverMapProvider.notifier).setMapController(controller);
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
