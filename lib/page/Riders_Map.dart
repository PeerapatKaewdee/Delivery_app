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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(children: [
          FilledButton(
              onPressed: () async {
                Position position = await _determinePosition();
                log('$latLng ${position.longitude}');
                latLng = LatLng(position.latitude, position.longitude);
                mapController.move(latLng, mapController.camera.zoom);
                setState(() {});
              },
              child: const Text("Get location")),
          Expanded(
            flex: 4,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: latLng,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  // Display map tiles from any source
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                  userAgentPackageName: 'com.example.app',
                  maxNativeZoom:
                      19, // Scale tiles when the server doesn't support higher zoom levels
                  // And many more recommended properties!
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                        point: latLng,
                        width: 40,
                        height: 40,
                        child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                                Icons
                                    .motorcycle_rounded, // Icon of a motorcycle
                                color: Colors.white, // Color of the icon
                                size: 30)), // Size of the icon
                        alignment: Alignment.center),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            flex: 1,
            child: Column(
              children: [
                FilledButton(onPressed: () {}, child: Text("ถึงจุดหมายแแล้ว"))
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

Future<Position> _determinePosition() async {
  log('message');
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    log('2');
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      log("12"); // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    log('123');
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
