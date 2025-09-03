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
  Future<LocationData?>? _locationFuture = null;
  NLatLng? _currentPosition;
  late final NaverMapController _mapController;

  @override
  void initState() {
    super.initState();
    _loadEnvFile();
    WidgetsFlutterBinding.ensureInitialized();
    _initNaverMap();
    _locationFuture = _fetchPosition();
  }

  Future<void> _loadEnvFile() async {
    await dotenv.load(fileName: ".env");
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
          return null; // 서비스가 거부되면 null 반환
        }
      }

      var permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return null; // 권한이 거부되면 null 반환
        }
      }

      // 모든 권한이 허용되면 현재 위치를 가져와서 반환!
      return await location.getLocation();
    } catch (e) {
      print("위치 정보를 가져오는 데 실패했습니다: $e");
      return null; // 에러가 발생해도 null 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FutureBuilder를 사용해서 _locationFuture의 상태를 지켜보자!
      body: Stack(children: [
        FutureBuilder<LocationData?>(
          future: _locationFuture,
          // snapshot에는 Future의 상태와 데이터가 들어있어.
          builder: (context, snapshot) {
            // 1. 로딩 중일 때 (아직 데이터가 없을 때)
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

            // 2. 데이터가 있지만 null일 때 (권한 거부 등)
            if (snapshot.data == null) {
              return const Center(
                child: Text("위치 권한을 허용해주세요."),
              );
            }

            // 3. 성공적으로 위치 정보를 가져왔을 때!
            final locationData = snapshot.data!;
            print("${locationData.latitude} / ${locationData.longitude}");
            _currentPosition =
                NLatLng(locationData.latitude!, locationData.longitude!);

            if (_currentPosition == null) {
              return Placeholder();
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
        Positioned(
            top: 750,
            left: 320,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
                          target: _currentPosition);

                      cameraUpdate.setAnimation(
                          animation: NCameraAnimation.fly,
                          duration: Duration(seconds: 2));

                      _mapController.updateCamera(cameraUpdate);
                    });
                  },
                  icon: Icon(Icons.gps_fixed_rounded)),
            ))
      ]),
    );
  }
}
