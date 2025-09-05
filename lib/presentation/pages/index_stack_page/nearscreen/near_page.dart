import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';

class NearPage extends StatefulWidget {
  const NearPage({super.key});

  @override
  State<NearPage> createState() => _NearPageState();
}

class _NearPageState extends State<NearPage> {
  Future<LocationData?>? _locationFuture;
  NLatLng? _currentPosition;
  late final NaverMapController _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _initNaverMap();
    _locationFuture = _fetchPosition();
  }

  Future<void> _initNaverMap() async {
    await FlutterNaverMap().init(
        clientId: dotenv.env['NAVER_CLIENT_ID']!,
        onAuthFailed: (ex) {
          print("인증 실패: $ex");
        });
  }

  Future<LocationData?> _fetchPosition() async {
    final location = Location();
    try {
      var serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }

      var permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return null;
        }
      }

      return await location.getLocation();
    } catch (e) {
      print("위치 정보를 가져오는 데 실패했습니다: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        FutureBuilder<LocationData?>(
          future: _locationFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("현재 위치를 가져오는 중..."),
                  ],
                ),
              );
            }

            if (snapshot.data == null) {
              return const Center(
                child: Text("위치 권한을 허용해주세요."),
              );
            }

            final locationData = snapshot.data!;
            print("${locationData.latitude} / ${locationData.longitude}");
            _currentPosition =
                NLatLng(locationData.latitude!, locationData.longitude!);

            if (_currentPosition == null) {
              return const Placeholder();
            }

            return NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition:
                    NCameraPosition(target: _currentPosition!, zoom: 15),
              ),
              onMapReady: (controller) {
                _mapController = controller;
                final marker = NMarker(
                  id: "my_location",
                  position: _currentPosition!,
                  caption: const NOverlayCaption(text: "내 위치"),
                );
                controller.addOverlay(marker);
                print("네이버 맵 준비 완료! 현재 위치에 마커 표시!");
              },
            );
          },
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null) {
            final cameraUpdate =
                NCameraUpdate.scrollAndZoomTo(target: _currentPosition!);

            cameraUpdate.setAnimation(
                animation: NCameraAnimation.fly,
                duration: const Duration(seconds: 2));

            _mapController.updateCamera(cameraUpdate);
          }
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.gps_fixed_rounded),
      ),
    );
  }
}
