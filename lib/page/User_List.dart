import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/page/User_send.dart';
import 'package:delivery_app/page/User_map.dart'; // Import UserMapPage
import 'package:delivery_app/page/User_Profile.dart'; // Import UserProfilePage
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum DeliveryStatus { status1, status2, status3 }

class UserListPage extends StatefulWidget {
  final int id; // Change to final
  UserListPage({super.key, required this.id});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  DeliveryStatus _selectedStatus = DeliveryStatus.status1; // Current status
  int _selectedIndex = 2; // Default index for UserListPage
  // File? _image;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on the index
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserSendPage(id: widget.id)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserMapPage(
                    id: widget.id,
                  )),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserProfilePage(
                    id: widget.id,
                  )),
        );
        break;
      // case 2: // Stay on UserListPage
    }
  }

  void _pickImage() {
    // Logic to pick image
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการรับ'), // AppBar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = DeliveryStatus.status1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue color
                  ),
                  child: const Text('สถานะ 1'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = DeliveryStatus.status2;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow, // Yellow color
                  ),
                  child: const Text('สถานะ 2'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = DeliveryStatus.status3;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green color
                  ),
                  child: const Text('สถานะ 3'),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Center(
              child: Text(
                'สถานะ: ${_selectedStatus.name}', // ใช้ชื่อ enum
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 50),
            // Firestore ListView
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Delivery')
                    .where('reship_id', isEqualTo: widget.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('ไม่มีข้อมูลรายการส่งสินค้า'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final deliveryData = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          // ตรวจสอบว่ามีพิกัดใน Firestore
                          if (deliveryData['latitude'] != null &&
                              deliveryData['longitude'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPage(
                                  id: widget.id,
                                  latitude: deliveryData['lat'],
                                  longitude: deliveryData['lng'],
                                ),
                              ),
                            );
                          } else {
                            // แสดงข้อความเตือนถ้าไม่มีพิกัด
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('ไม่มีพิกัดสำหรับการแสดงแผนที่')),
                            );
                          }
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'รายละเอียดของที่ส่ง',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'รายละเอียดสินค้า: ${deliveryData['description'] ?? 'ไม่มีรายละเอียด'}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'สถานะ: ${deliveryData['status'] ?? 'ไม่มีสถานะ'}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // BottomNavigationBar section
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.move_to_inbox),
            label: 'รายการส่ง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'รายการรับ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ],
        currentIndex: _selectedIndex, // Set default status to show Receipt List
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MapPage extends StatefulWidget {
  final int id;
  final double latitude; // เพิ่มพิกัด latitude
  final double longitude; // เพิ่มพิกัด longitude

  MapPage({
    super.key,
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _goToLocation();
  }

  void _goToLocation() {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(widget.latitude, widget.longitude),
        14.0, // กำหนดระดับการซูม
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แผนที่')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 14.0, // ระดับการซูมเริ่มต้น
        ),
        markers: {
          Marker(
            markerId: MarkerId('delivery_location'),
            position: LatLng(widget.latitude, widget.longitude),
            infoWindow: InfoWindow(title: 'สถานที่ส่งสินค้า'),
          ),
        },
      ),
    );
  }
}
