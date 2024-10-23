import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/page/User_send.dart';
import 'package:delivery_app/page/User_map.dart'; // Import UserMapPage
import 'package:delivery_app/page/User_Profile.dart'; // Import UserProfilePage
import 'package:flutter/material.dart';

enum DeliveryStatus { status1, status2, status3 }

class UserListPage extends StatefulWidget {
  int id = 0;
  UserListPage({super.key, required id});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  DeliveryStatus _selectedStatus = DeliveryStatus.status1; // Current status
  int _selectedIndex = 2; // Default index for UserListPage

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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Delivery')
                  .where('send_id',
                      isEqualTo:
                          1) // แทนที่ 'your_send_id' ด้วยค่าที่คุณต้องการ
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                    ),
                  );
                  return const Center(child: Text('เกิดข้อผิดพลาด'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('ไม่มีข้อมูลรายการส่งสินค้า'));
                }

                final items = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index].data() as Map<String, dynamic>;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(
                          item['description'] ??
                              'ไม่มีรายละเอียด', // แสดงรายละเอียดสินค้า
                          style: const TextStyle(fontSize: 18),
                        ),
                        trailing: const Icon(Icons
                            .arrow_forward), // ไอคอนสำหรับรายละเอียดเพิ่มเติม
                      ),
                    );
                  },
                );
              },
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
