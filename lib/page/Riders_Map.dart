import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RidersMapPage extends StatefulWidget {
  final String docId;
  final int id;

  const RidersMapPage({super.key, required this.id, required this.docId});

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
  LatLng riderLatLng = const LatLng(0, 0);
  LatLng destinationLatLng = const LatLng(0, 0);
  bool isLoading = true;
  bool isDestinationReached = false;
  String errorMessage = '';
  double distanceToDestination = double.infinity;

  // เพิ่มตัวแปรใหม่
  String currentStatus = 'pending'; // สถานะเริ่มต้น
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentStatus(); // เพิ่มการดึงสถานะปัจจุบัน
  }

  // เพิ่มฟังก์ชันดึงสถานะปัจจุบัน
  Future<void> _fetchCurrentStatus() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('Delivery')
          .doc(widget.docId)
          .get();
      if (doc.exists) {
        setState(() {
          currentStatus = doc.data()?['status'] ?? 'pending';
        });
      }
    } catch (e) {
      log('Error fetching status: $e');
    }
  }

  // เพิ่มฟังก์ชันถ่ายรูป
  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      log('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถถ่ายรูปได้')),
        );
      }
    }
  }

  // เพิ่มฟังก์ชันอัพโหลดรูป
  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      setState(() {
        isUploading = true;
      });

      String fileName =
          'delivery_${widget.docId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('delivery_images')
          .child(fileName);

      await ref.putFile(_imageFile!);
      String downloadURL = await ref.getDownloadURL();

      // เก็บ URL ลงใน Firestore
      await FirebaseFirestore.instance
          .collection('Delivery')
          .doc(widget.docId)
          .update({
        'photos': FieldValue.arrayUnion([
          {
            'url': downloadURL,
            'status': currentStatus,
            'timestamp': FieldValue.serverTimestamp(),
          }
        ]),
      });

      setState(() {
        isUploading = false;
        _imageFile = null;
      });

      return downloadURL;
    } catch (e) {
      log('Error uploading image: $e');
      setState(() {
        isUploading = false;
      });
      return null;
    }
  }

  // ปรับปรุงฟังก์ชันอัพเดทสถานะ
  Future<void> _updateDeliveryStatus(String newStatus) async {
    try {
      // ถ่ายรูปก่อนอัพเดทสถานะ
      await _takePicture();
      if (_imageFile == null && newStatus != 'delivered') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กรุณาถ่ายรูปเพื่อยืนยันสถานะ')),
          );
        }
        return;
      }

      await FirebaseFirestore.instance
          .collection('Delivery')
          .doc(widget.docId)
          .update({
        'status': newStatus,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        currentStatus = newStatus;
      });

      // แสดง Dialog เมื่ออัพเดทสถานะสำเร็จ
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('อัพเดทสถานะสำเร็จ'),
            content: Text(_getStatusMessage(newStatus)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // ถ้าจัดส่งสำเร็จให้กลับไปหน้า RidersGetPage
                  if (newStatus == 'delivered') {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
        );
      }
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'picked_up':
        return 'รับสินค้าเรียบร้อยแล้ว';
      case 'delivering':
        return 'กำลังจัดส่งสินค้า';
      case 'delivered':
        return 'จัดส่งสินค้าสำเร็จ';
      default:
        return 'อัพเดทสถานะเรียบร้อย';
    }
  }

  // ปรับปรุง build method
  @override
  Widget build(BuildContext context) {
    // ... โค้ดส่วน loading และ error checking คงเดิม ...

    return Scaffold(
      appBar: AppBar(
        title: const Text("แผนที่การจัดส่ง"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (riderLatLng != const LatLng(0, 0)) {
                mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: riderLatLng, zoom: 17),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
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
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (distanceToDestination != double.infinity) ...[
                  Text(
                    'ระยะทางถึงจุดหมาย: ${(distanceToDestination / 1000).toStringAsFixed(2)} กม.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                ],
                // แสดงสถานะปัจจุบัน
                Text(
                  'สถานะปัจจุบัน: ${_getStatusMessage(currentStatus)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (isUploading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      // ปุ่มรับสินค้า
                      if (currentStatus == 'pending')
                        ElevatedButton(
                          onPressed: () => _updateDeliveryStatus('picked_up'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('รับสินค้า'),
                        ),
                      const SizedBox(height: 8),
                      // ปุ่มเริ่มจัดส่ง
                      if (currentStatus == 'picked_up')
                        ElevatedButton(
                          onPressed: () => _updateDeliveryStatus('delivering'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('เริ่มจัดส่ง'),
                        ),
                      const SizedBox(height: 8),
                      // ปุ่มจัดส่งสำเร็จ
                      if (currentStatus == 'delivering')
                        ElevatedButton(
                          onPressed: isDestinationReached
                              ? () => _updateDeliveryStatus('delivered')
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Text(
                            isDestinationReached
                                ? "ยืนยันการจัดส่ง"
                                : "ยังไม่ถึงจุดหมาย",
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
