import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class RidersMapPage extends StatefulWidget {
  const RidersMapPage({super.key});

  @override
  State<RidersMapPage> createState() => _RidersMapPageState();
}

class _RidersMapPageState extends State<RidersMapPage> {
  LatLng latLng = const LatLng(16.246825669508297, 103.25199289277295);
  MapController mapController = MapController();
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    _startLocationTracking(); // เริ่มติดตามตำแหน่งเมื่อเริ่มหน้า
  }

  @override
  void dispose() {
    positionStream?.cancel(); // ยกเลิกการติดตามเมื่อออกจากหน้า
    super.dispose();
  }

  void _startLocationTracking() async {
    // ตรวจสอบสิทธิ์ตำแหน่ง
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Future.error('Location permissions are permanently denied.');
    }

    // เริ่มการติดตามตำแหน่งแบบ real-time
    positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // อัปเดตเมื่อเคลื่อนที่อย่างน้อย 10 เมตร
      ),
    ).listen((Position position) {
      log('ตำแหน่งใหม่: ${position.latitude}, ${position.longitude}');
      setState(() {
        latLng = LatLng(position.latitude, position.longitude);
        mapController.move(latLng, mapController.camera.zoom);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("MAP")),
      ),
      body: Center(
        child: Column(children: [
          SizedBox(
            height: 30,
          ),
          Expanded(
            flex: 6,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: latLng,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latLng,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.motorcycle_rounded,
                        color: Color.fromARGB(255, 0, 0, 0),
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                FilledButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(255, 0, 222, 22), // สีพื้นหลังของปุ่ม
                    shadowColor: Colors.black, // สีของเงา
                    elevation: 10, // ความสูงของเงา
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // มุมโค้งของปุ่ม
                    ),
                  ),
                  child: const Text(
                    "ถึงจุดหมายแล้ว",
                    style: TextStyle(
                      color: Colors.white, // สีของตัวหนังสือ
                      fontSize: 18, // ขนาดตัวหนังสือ
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
