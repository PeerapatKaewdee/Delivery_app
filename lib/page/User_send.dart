import 'package:flutter/material.dart';

class UserSendPage extends StatefulWidget {
  const UserSendPage({super.key});

  @override
  State<UserSendPage> createState() => _UserSendPageState();
}

class _UserSendPageState extends State<UserSendPage> {
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _itemDetailsController = TextEditingController();

  int _selectedIndex = 0; // ใช้สำหรับเก็บสถานะของ Bottom Navigation

  void _createDelivery() {
    String receiverPhone = _receiverPhoneController.text;
    String itemDetails = _itemDetailsController.text;

    // ตรวจสอบข้อมูลและประมวลผลที่นี่
    if (receiverPhone.isNotEmpty && itemDetails.isNotEmpty) {
      // ทำการบันทึกข้อมูล
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
    // เพิ่มการนำทางไปยังหน้าอื่น ๆ ตามที่เลือก
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างรายการส่งสินค้า'),
      ),
      body: Center( // ใช้ Center widget เพื่อจัดให้อยู่กลาง
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // จัดให้อยู่กลางตามแนวตั้ง
            crossAxisAlignment: CrossAxisAlignment.center, // จัดให้อยู่กลางตามแนวนอน
            children: [
              const Text(
                'ค้นหาผู้รับ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: 300, // ปรับขนาดของช่องกรอกเบอร์โทร
                decoration: BoxDecoration(
                  color: Colors.white, // สีพื้นหลัง
                  borderRadius: BorderRadius.circular(8), // มุมมน
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3), // เงา
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // เงาอยู่ด้านล่าง
                    ),
                  ],
                ),
                child: TextField(
                  controller: _receiverPhoneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none, // ไม่มีขอบ
                    ),
                    // ไม่ใส่ labelText เพื่อไม่ให้มีข้อความบนขอบ
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 8), // เว้นระยะห่างระหว่างช่องกรอกกับปุ่ม
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // ปุ่มสีน้ำเงิน
                ),
                onPressed: () {
                  // เพิ่มฟังก์ชันสำหรับค้นหาผู้รับที่นี่
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
                width: 300, // ปรับขนาดให้เท่ากับช่องเบอร์โทร
                decoration: BoxDecoration(
                  color: Colors.white, // สีพื้นหลัง
                  borderRadius: BorderRadius.circular(8), // มุมมน
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3), // เงา
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // เงาอยู่ด้านล่าง
                    ),
                  ],
                ),
                child: TextField(
                  controller: _itemDetailsController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none, // ไม่มีขอบ
                    ),
                    // ไม่ใส่ labelText เพื่อไม่ให้มีข้อความบนขอบ
                  ),
                  maxLines: 3, // อนุญาตให้มีหลายบรรทัด
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // ปุ่มสีเขียว
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
            icon: Icon(Icons.move_to_inbox), // ไอคอนสำหรับรายการส่ง
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
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
