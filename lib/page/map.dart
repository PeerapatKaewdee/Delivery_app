import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  List<LatLng> routeCoords = [];

  @override
  void initState() {
    super.initState();
    _getRoute();
  }

  // ฟังก์ชันสำหรับดึงเส้นทางจาก Google Directions API
  Future<List<LatLng>> getRouteCoordinates(LatLng start, LatLng end) async {
    final String apiKey =
        'AIzaSyAJKvbKrjAnGxPiosNv9WWwZIx6CWDAKHw'; // ใส่ Google API Key ของคุณตรงนี้
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(response.body); // ดีบัก response ที่ได้จาก API

      if (jsonResponse['routes'].isNotEmpty) {
        var points = jsonResponse['routes'][0]['overview_polyline']['points'];
        return decodePolyline(points);
      } else {
        print("No routes found");
        return [];
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }

  // ฟังก์ชันถอดรหัสโพลีไลน์เพื่อแปลงเป็น List<LatLng>
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  // ฟังก์ชันดึงเส้นทางและตั้งค่าโพลีไลน์
  void _getRoute() async {
    LatLng start =
        LatLng(37.42796133580664, -122.085749655962); // พิกัดเริ่มต้น
    LatLng end = LatLng(37.42496133180663, -122.081749656); // พิกัดปลายทาง
    print("Fetching route from $start to $end"); // ดูพิกัดที่ส่งไปยัง API
    routeCoords = await getRouteCoordinates(start, end);

    if (routeCoords.isNotEmpty) {
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route_1'),
            points: routeCoords,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    } else {
      print("No coordinates received");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Route on Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.42796133580664, -122.085749655962),
          zoom: 14.0,
        ),
        polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
