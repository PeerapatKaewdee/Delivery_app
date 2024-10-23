import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:delivery_app/page/User_Profile.dart';
import 'package:delivery_app/page/User_send.dart';
import 'package:delivery_app/page/User_list.dart'; // Import UserListPage
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For image selection
import 'dart:io'; // For file handling

class UserMapPage extends StatefulWidget {
  final int id;
  UserMapPage({super.key, required this.id});

  @override
  State<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  int _selectedStatus = 0; // Current status
  int _selectedIndex = 1; // BottomNavigationBar status
  File? _image; // Variable to hold the selected image

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera); // Open camera
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Store the captured image
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserSendPage(id: widget.id)),
      );
    } else if (index == 1) {
      // Stay on UserMapPage
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UserListPage(
                  id: widget.id,
                )), // Navigate to UserListPage
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UserProfilePage(
                  id: widget.id,
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการส่ง'), // AppBar title
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
                      _selectedStatus = 0; // Waiting for rider
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue color
                  ),
                  child: const Text('รอไรเดอร์รับงาน'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = 1; // In delivery
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow, // Yellow color
                  ),
                  child: const Text('กำลังจัดส่ง'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = 2; // Delivery complete
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green color
                  ),
                  child: const Text('ส่งสำเร็จ'),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Center(
              child: Text(
                _selectedStatus == 0
                    ? 'สถานะ: รอไรเดอร์รับงาน'
                    : _selectedStatus == 1
                        ? 'สถานะ: กำลังจัดส่ง'
                        : 'สถานะ: ส่งสำเร็จ',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 50),
            // Use StreamBuilder to fetch data from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Delivery')
                    .where('send_id',
                        isEqualTo:
                            widget.id) // Replace with the desired send_id
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('ไม่มีข้อมูลการจัดส่ง'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final deliveryData = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      return Card(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: _pickImage, // Select image on tap
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      image: _image != null
                                          ? DecorationImage(
                                              image: FileImage(_image!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: _image == null
                                        ? const Center(
                                            child: Text(
                                              'ถ่ายรูป',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ],
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
        currentIndex: _selectedIndex, // Set default status
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
