import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/config/Google_key.dart';

class RidersMapPage extends StatefulWidget {
  final String docId; // ใช้สำหรับระบุเอกสารใน Firestore
  final int id;

  RidersMapPage({super.key, required this.id, required this.docId});

  @override
  State<RidersMapPage> createState() => _RidersMapPageState();
}

class _RidersMapPageState extends State<RidersMapPage> {
  GoogleMapController? mapController;
  StreamSubscription<Position>? positionStream;
  Marker? riderMarker;
  Marker? destinationMarker;
  List<LatLng> polylineCoordinates = [];
  Polyline? routePolyline;
  LatLng riderLatLng =
      LatLng(0, 0); // เริ่มต้นด้วยตำแหน่งไรเดอร์ที่ยังไม่ถูกกำหนด
  LatLng destinationLatLng = LatLng(0, 0); // เริ่มต้นด้วยตำแหน่งปลายทาง

  @override
  void initState() {
    super.initState();
    _startLocationTracking(); // เริ่มติดตามตำแหน่งไรเดอร์แบบเรียลไทม์
    _fetchDestination(); // ดึงตำแหน่งปลายทางจาก Firestore
  }

  @override
  void dispose() {
    positionStream?.cancel(); // ยกเลิกการติดตามเมื่อออกจากหน้า
    super.dispose();
  }

  // ฟังก์ชันดึงข้อมูลตำแหน่งปลายทางจาก Firestore โดยใช้ docId
  Future<void> _fetchDestination() async {
    try {
      log('Fetching destination...');
      var docSnapshot = await FirebaseFirestore.instance
          .collection('Delivery')
          .doc(widget.docId) // ใช้ docId ที่ส่งมา
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        var reshipLocation = data?['reshiplocation'];

        log('Data from Firestore: $data'); // Log ข้อมูลที่ดึงมา

        if (reshipLocation is Map<String, dynamic>) {
          var latitude = reshipLocation['lat'];
          var longitude = reshipLocation['lng'];

          log('Reship location lat: $latitude, lng: $longitude'); // Log ค่า lat lng

          setState(() {
            destinationLatLng = LatLng(latitude, longitude);
            destinationMarker = Marker(
              markerId: const MarkerId('destination'),
              position: destinationLatLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            );
            log('Destination LatLng set: $destinationLatLng'); // Log การตั้งค่าตำแหน่ง
          });
        } else {
          log('Invalid reshiplocation data format');
        }
      } else {
        log('Document not found');
      }
    } catch (e) {
      log('Error fetching destination: $e');
    }
  }

  // ฟังก์ชันติดตามตำแหน่งไรเดอร์และอัปเดต Firestore แบบเรียลไทม์
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
        riderLatLng = LatLng(13.72264, 100.52931); // ทดสอบด้วยตำแหน่งที่กำหนด
        log('Rider location updated: $riderLatLng');
        riderMarker = Marker(
          markerId: const MarkerId('rider'),
          position: riderLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );

        mapController?.animateCamera(
          CameraUpdate.newLatLng(riderLatLng),
        );

        // อัปเดตตำแหน่งไรเดอร์ใน Firestore
        FirebaseFirestore.instance
            .collection('Delivery')
            .doc(widget.docId.toString())
            .update({
          'riderLocation':
              GeoPoint(riderLatLng.latitude, riderLatLng.longitude),
        });
        _getRouteDirections(); // เรียกฟังก์ชันดึงเส้นทาง
      });
    });
  }

  // ฟังก์ชันดึงเส้นทางจาก Google Directions API
  // สร้าง instance ของ PolylinePoints
  PolylinePoints polylinePoints = PolylinePoints();

  Future<void> _getRouteDirections() async {
    log("Rider Location: $riderLatLng");
    log("Destination LatLng: $destinationLatLng");

    if (riderLatLng == LatLng(0, 0) || destinationLatLng == LatLng(0, 0)) {
      log("Invalid rider or destination location.");
      return; // ไม่ทำการเรียกหากตำแหน่งไม่ถูกต้อง
    }

    // สร้าง PolylineRequest
    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(riderLatLng.latitude, riderLatLng.longitude),
      destination:
          PointLatLng(destinationLatLng.latitude, destinationLatLng.longitude),
      transitMode: 'bicycling', // ใช้ 'bicycling' เป็น String
      mode: TravelMode.driving, // ตั้งค่า TravelMode ที่คุณต้องการ
    );

    // เรียกใช้ getRouteBetweenCoordinates
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: Google_AIP_KEY, // แทนที่ด้วย API Key ของคุณ
      request: request,
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        routePolyline = Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: polylineCoordinates,
        );
      });
    } else {
      log("No route found: ${result.errorMessage}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Rider Map")),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: riderLatLng,
          zoom: 15,
        ),
        markers: {
          if (riderMarker != null) riderMarker!,
          if (destinationMarker != null) destinationMarker!,
        },
        polylines: {
          if (routePolyline != null) routePolyline!,
        },
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            // ฟังก์ชันที่ใช้เมื่อถึงจุดหมาย
          },
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
      ),
    );
  }
}
