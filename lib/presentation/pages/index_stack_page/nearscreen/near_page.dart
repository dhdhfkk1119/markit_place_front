import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class NearPage extends StatelessWidget {
  const NearPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('네이버 지도 - 내 위치'),
      ),
      body: NaverMap(
        // options 부분만 수정하면 돼!
        options: const NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(37.5666102, 126.9783881), // 초기 위치는 서울 시청
            zoom: 15,
          ),
          // 👇 이 코드 한 줄만 추가하면 돼!
          locationButtonEnable: true,
        ),
      ),
    );
  }
}
