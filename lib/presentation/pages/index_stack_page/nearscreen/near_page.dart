import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/naver_map/location_tracking_mode.dart';
import '../../../../domain/providers/naver_map_notifier.dart';

class NearPage extends ConsumerWidget {
  const NearPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch로 현재 추적 모드를 계속 감시해!
    final currentTrackingMode = ref.watch(naverMapProvider);

    // 상태에 따라 아이콘 결정 (이전과 동일)
    final IconData fabIcon;
    switch (currentTrackingMode) {
      case NLocationTrackingMode.face:
        fabIcon = Icons.explore; // 방향 추적 아이콘
        break;
      default:
        fabIcon = Icons.my_location; // 꺼짐 & 위치 추적 아이콘
    }

    // 상태에 따라 색상 결정 (이전과 동일)
    final Color fabColor = (currentTrackingMode == NLocationTrackingMode.none)
        ? Colors.black54 // 꺼짐 = 회색
        : Colors.blue; // 켜짐 = 파란색

    return Scaffold(
      body: NaverMap(
        onMapReady: (controller) {
          ref.read(naverMapProvider.notifier).setMapController(controller);
        },
        // 👇 사용자가 지도를 움직이면 Notifier에게 알려주는 부분!
        onCameraChange: (reason, animated) {
          // GESTURE는 사용자가 직접 움직였다는 뜻이야.
          if (reason == NCameraUpdateReason.gesture) {
            ref.read(naverMapProvider.notifier).onCameraChangeByGesture();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        // 현재 추적 모드가 Follow일 때 파란색, 아니면 회색
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
