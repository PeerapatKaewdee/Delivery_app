import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RidersMapPage extends StatefulWidget {
  int id = 0;
  RidersMapPage({super.key, required this.id});

  @override
  State<RidersMapPage> createState() => _RidersMapPageState();
}

class _RidersMapPageState extends State<RidersMapPage> {
  LatLng riderLatLng = const LatLng(16.246825669508297, 103.25199289277295);
  LatLng destinationLatLng = const LatLng(0, 0); // ตำแหน่งปลายทาง
  MapController mapController = MapController();
  StreamSubscription<Position>? positionStream;
  List<LatLng> routePoints = []; // เก็บจุดต่างๆ ในเส้นทาง

  @override
  void initState() {
    super.initState();
    _fetchDestination(); // ดึงตำแหน่งปลายทางจาก Firestore
    _startLocationTracking(); // เริ่มติดตามตำแหน่งไรเดอร์แบบเรียลไทม์
  }

  @override
  void dispose() {
    positionStream?.cancel(); // ยกเลิกการติดตามเมื่อออกจากหน้า
    super.dispose();
  }

  // ฟังก์ชันดึงข้อมูลตำแหน่งปลายทางจาก Firestore
  Future<void> _fetchDestination() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('Deliveries')
        .doc(widget.id.toString())
        .get();

    if (docSnapshot.exists) {
      var data = docSnapshot.data();
      var reshipLocation = data?['reship_location'] as GeoPoint;
      setState(() {
        destinationLatLng =
            LatLng(reshipLocation.latitude, reshipLocation.longitude);
      });
    }
  }

  // ฟังก์ชันติดตามตำแหน่งไรเดอร์
  void _startLocationTracking() async {
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

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // อัปเดตเมื่อเคลื่อนที่อย่างน้อย 10 เมตร
      ),
    ).listen((Position position) {
      log('ตำแหน่งใหม่: ${position.latitude}, ${position.longitude}');
      setState(() {
        riderLatLng = LatLng(position.latitude, position.longitude);
        mapController.move(riderLatLng, 15.0); // อัปเดตตำแหน่งและซูม
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Rider Map")),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              flex: 6,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: riderLatLng,
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: riderLatLng,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.motorcycle_rounded,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      Marker(
                        point: destinationLatLng,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 222, 22),
                      shadowColor: Colors.black,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "ถึงจุดหมายแล้ว",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
