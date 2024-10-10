import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // เปลี่ยนเป็นไอคอนลูกศรย้อนกลับ
          onPressed: () {
            Navigator.pop(context); // กดแล้วจะย้อนกลับไปหน้าก่อนหน้า
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1, // ขนาดของครึ่งบน
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30), // การโค้งมนที่มุมล่างซ้าย
                bottomRight: Radius.circular(30), // การโค้งมนที่มุมล่างขวา
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
              padding: const EdgeInsets.all(16.0), // การเพิ่มระยะห่างรอบๆ ปุ่ม
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // ชิดด้านบน
                children: [
                  const SizedBox(height: 50), // เว้นระยะห่างระหว่างปุ่ม
                  // ปุ่ม "แก้ไขข้อมูล"
                  SizedBox(
                    width: 250, // กำหนดความกว้างของปุ่ม
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        // MaterialPageRoute(
                        //     builder: (context) => Editprofileuser(
                        //           idx: widget.idx,
                        //         )),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 255, 255, 255), // สีพื้นหลังของปุ่ม
                        padding: const EdgeInsets.symmetric(
                            vertical: 10), // ขนาดของปุ่ม
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5), // ขอบปุ่มโค้งมน
                        ),
                      ),
                      child: const Text(
                        'แก้ไขข้อมูล',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15), // เว้นระยะห่างระหว่างปุ่ม
                  // ปุ่ม "ออกจากระบบ" พร้อมยืนยัน
                  SizedBox(
                    width: 250, // กำหนดความกว้างของปุ่ม
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                "ยืนยัน",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              content: const Text(
                                "คุณต้องการออกจากระบบใช่หรือไม่?",
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // Navigator.pushAndRemoveUntil(
                                        //   context,
                                        //   MaterialPageRoute(builder: (context) => Loginpage()), // ไปหน้า LoginPage
                                        //   (route) => false, // ลบหน้าทั้งหมดออกจาก stack
                                        // );
                                      },
                                      child: const Text("ใช่"),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            const Color(0xFF2445EF),
                                      ),
                                    ),
                                    const SizedBox(width: 70),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // ปิด dialog เมื่อกด "ไม่"
                                      },
                                      child: const Text("ไม่"),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            Color.fromARGB(255, 251, 61, 61),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 255, 255, 255), // สีพื้นหลังของปุ่ม
                        padding: const EdgeInsets.symmetric(
                            vertical: 10), // ขนาดของปุ่ม
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
    );
  }
}
