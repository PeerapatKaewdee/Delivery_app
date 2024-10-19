import 'package:delivery_app/page/User_send.dart';
import 'package:delivery_app/page/User_map.dart'; // Import UserMapPage
import 'package:flutter/material.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  int _selectedStatus = 0; // Current status
  List<String> _items = [
    "รายการที่ 1",
    "รายการที่ 2",
    "รายการที่ 3"
  ]; // Items to display

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
                      _selectedStatus = 0; // Status for item 1
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
                      _selectedStatus = 1; // Status for item 2
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
                      _selectedStatus = 2; // Status for item 3
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
                _selectedStatus == 0
                    ? 'สถานะ: สถานะ 1'
                    : _selectedStatus == 1
                        ? 'สถานะ: สถานะ 2'
                        : 'สถานะ: สถานะ 3',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 50),
            // Card for displaying items
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _items[index],
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Icon(Icons.arrow_forward), // Icon for details
                        ],
                      ),
                    ),
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
        currentIndex: 2, // Set default status to show Receipt List
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            // Navigate based on BottomNavigationBar selection
            if (index == 0) {
              // Navigate to UserSendPage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserSendPage(
                          id: 1,
                        )),
              );
            } else if (index == 1) {
              // Navigate to UserMapPage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserMapPage()),
              );
            } else if (index == 2) {
              // Stay on UserListPage
            } else if (index == 3) {
              // Navigate to Profile Page (not implemented yet)
            }
          });
        },
      ),
    );
  }
}
