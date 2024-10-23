import 'package:flutter/material.dart';
import 'package:delivery_app/page/User_send.dart';
import 'package:delivery_app/page/User_map.dart';
import 'package:delivery_app/page/User_list.dart'; // Import UserListPage

class UserProfilePage extends StatefulWidget {
  int id = 0;
  UserProfilePage({Key? key, required id}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  int _selectedIndex = 3; // Default index for UserProfilePage

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserSendPage(id: widget.id)),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserMapPage(
                    id: widget.id,
                  )),
        );
      } else if (index == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserListPage(id: widget.id)),
        );
      } else if (index == 3) {
        // Stay on UserProfilePage
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // กำหนดให้ไอคอนเป็นสีขาว
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2445EF),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        leading: const SizedBox(), // เอาลูกศรออก
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1, // ขนาดของครึ่งบน
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30), // โค้งมนที่มุมล่างซ้าย
                bottomRight: Radius.circular(30), // โค้งมนที่มุมล่างขวา
              ),
              child: Container(
                color: const Color(0xFF2445EF), // สีของ Container ในครึ่งบน
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 70, // ขนาดของไอคอนโปรไฟล์
                        backgroundColor: Color.fromARGB(
                            255, 220, 220, 220), // สีพื้นหลังของไอคอนโปรไฟล์
                        child: Icon(
                          Icons.person, // ใช้ไอคอนโปรไฟล์
                          size: 80, // ขนาดของไอคอน
                          color: Color.fromARGB(255, 0, 0, 0), // สีของไอคอน
                        ),
                      ),
                      SizedBox(height: 10), // เว้นระยะห่างระหว่างไอคอนและชื่อ
                      Text(
                        'Deconto Tomson', // ชื่อที่จะแสดง
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2, // ขนาดของครึ่งล่าง
            child: Padding(
              padding: const EdgeInsets.all(16.0), // เพิ่มระยะห่างรอบๆ ปุ่ม
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // ชิดด้านบน
                children: [
                  const SizedBox(height: 50), // เว้นระยะห่างระหว่างปุ่ม
                  SizedBox(
                    width: 250, // กำหนดความกว้างของปุ่ม
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        ); // ฟังก์ชันที่ต้องการเมื่อกดปุ่ม "ออกจากระบบ"
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 255, 255, 255), // สีพื้นหลังของปุ่ม
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5), // ขอบปุ่มโค้งมน
                        ),
                      ),
                      child: const Text(
                        'ออกจากระบบ',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
