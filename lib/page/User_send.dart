import 'package:flutter/material.dart';
import 'package:delivery_app/page/User_Map.dart'; // Import UserMapPage
import 'package:delivery_app/page/User_List.dart'; // Import UserListPage

class UserSendPage extends StatefulWidget {
  const UserSendPage({super.key});

  @override
  State<UserSendPage> createState() => _UserSendPageState();
}

class _UserSendPageState extends State<UserSendPage> {
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _itemDetailsController = TextEditingController();

  int _selectedIndex = 0; // Store the status of Bottom Navigation

  void _createDelivery() {
    String receiverPhone = _receiverPhoneController.text;
    String itemDetails = _itemDetailsController.text;

    if (receiverPhone.isNotEmpty && itemDetails.isNotEmpty) {
      print('Receiver Phone: $receiverPhone');
      print('Item Details: $itemDetails');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('สร้างรายการส่งสินค้าสำเร็จ!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Navigate to UserMapPage for "รายการส่ง"
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserMapPage()),
      );
    } else if (index == 2) {
      // Navigate to UserListPage for "รายการรับ"
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserListPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างรายการส่งสินค้า'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'ค้นหาผู้รับ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _receiverPhoneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  // Add search receiver functionality here
                },
                child: const Text('ค้นหาผู้รับ'),
              ),
              const SizedBox(height: 16),
              const Text(
                'สร้างรายการส่งสินค้า',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _itemDetailsController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: _createDelivery,
                child: const Text('สร้างรายการส่งสินค้า'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.move_to_inbox), // Icon for Delivery List
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped, // Add onTap function
      ),
    );
  }
}
