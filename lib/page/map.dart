import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/config/Google_key.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  Set<Polyline> _polylines = {};
  LatLng _startLocation = LatLng(13.7563, 100.5018); // Bangkok
  LatLng _endLocation =
      LatLng(13.7611, 100.5588); // เปลี่ยนเป็นจุดปลายทางที่คุณต้องการ
  List<LatLng> _routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    _getRoute();
  }

  Future<void> _getRoute() async {
    log(Google_AIP_KEY.toString());
    String googleApiKey = '$Google_AIP_KEY'; // ใส่ API Key ของคุณที่นี่
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_startLocation.latitude},${_startLocation.longitude}&destination=${_endLocation.latitude},${_endLocation.longitude}&key=$googleApiKey';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var points = data['routes'][0]['overview_polyline']['points'];
      _createPolylines(points);
      _moveCameraToRoute();
    } else {
      throw Exception('Failed to load route');
    }
  }

  void _createPolylines(String points) {
    var polylinePoints = _convertToLatLng(_decodePoly(points));
    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        points: polylinePoints,
        width: 5,
      ));
      _routeCoordinates = polylinePoints; // บันทึกพ้อยส์เส้นทาง
    });
  }

  void _moveCameraToRoute() {
    LatLngBounds bounds = _getLatLngBounds(_routeCoordinates);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    double southWestLat = points[0].latitude;
    double southWestLng = points[0].longitude;
    double northEastLat = points[0].latitude;
    double northEastLng = points[0].longitude;

    for (LatLng point in points) {
      if (point.latitude < southWestLat) {
        southWestLat = point.latitude;
      }
      if (point.longitude < southWestLng) {
        southWestLng = point.longitude;
      }
      if (point.latitude > northEastLat) {
        northEastLat = point.latitude;
      }
      if (point.longitude > northEastLng) {
        northEastLng = point.longitude;
      }
    }

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  List<LatLng> _convertToLatLng(List<List<double>> points) {
    return points.map<LatLng>((point) {
      return LatLng(point[0], point[1]);
    }).toList();
  }

  List<List<double>> _decodePoly(String poly) {
    List<List<double>> coordinates = [];
    for (int i = 0; i < poly.length;) {
      int b = 0;
      int shift = 0;
      int result = 0;

      while (true) {
        b = poly.codeUnitAt(i++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
        if (b < 0x20) break;
      }

      int latitudeChange = ((result >> 1) ^ ~(~0 >> 1));
      double latitude = latitudeChange.toDouble() +
          (coordinates.isEmpty ? 0 : (coordinates.last[0] * 1E5).toDouble());
      coordinates.add([latitude / 1E5, 0.0]);

      result = 0;
      shift = 0;

      while (true) {
        b = poly.codeUnitAt(i++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
        if (b < 0x20) break;
      }

      int longitudeChange = ((result >> 1) ^ ~(~0 >> 1));
      double longitude = longitudeChange.toDouble() +
          (coordinates.isEmpty ? 0 : (coordinates.last[1] * 1E5).toDouble());
      coordinates[coordinates.length - 1][1] = longitude / 1E5;
    }
    return coordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map with Route')),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _startLocation,
          zoom: 14.0,
        ),
        polylines: _polylines,
        markers: {
          Marker(markerId: MarkerId('start'), position: _startLocation),
          Marker(markerId: MarkerId('end'), position: _endLocation),
        },
      ),
    );
  }
}
