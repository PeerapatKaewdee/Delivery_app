import 'package:flutter/material.dart';

class RidersGetPage extends StatefulWidget {
  const RidersGetPage({super.key});

  @override
  State<RidersGetPage> createState() => _RidersGetPageState();
}

class _RidersGetPageState extends State<RidersGetPage> {
  @override
  Widget build(BuildContext context) {
    // ใช้ MediaQuery เพื่อดึงข้อมูลเกี่ยวกับขนาดหน้าจอ
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'หน้าแรก',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0), // สีข้อความในแอพบาร์
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color.fromARGB(255, 255, 255, 255), // สีพื้นหลังของแอพบาร์
        elevation: 0.0, // ความสูงของเงา (กำหนดเป็น 0 เพื่อลบเงา)
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // ทำงานเมื่อกดปุ่มเมนู
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // ทำงานเมื่อกดปุ่มค้นหา
            },
          ),
        ],
        centerTitle: true, // จัดกึ่งกลางชื่อเรื่อง
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(),
        ),
      ),
      body: Center(
        // Center เพื่อจัดให้อยู่ตรงกลาง
        child: SingleChildScrollView(
          // SingleChildScrollView เพื่อเลื่อนเมื่อเนื้อหาเกินขนาดหน้าจอ
          child: Column(
            children: [
              Card(
                color: Color.fromARGB(255, 0, 222, 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4.0,
                margin: const EdgeInsets.all(15.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Order ID
                      const Text(
                        'Order#123',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      // Food image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                          'https://tecnogasthai.com/wp-content/uploads/2022/07/pic-01-3.png', // เปลี่ยน URL เป็นรูปอาหารที่คุณต้องการ
                          height: screenSize.height *
                              0.10, // ปรับความสูงตามสัดส่วนหน้าจอ (25% ของความสูงหน้าจอ)
                          width: screenSize.width *
                              0.5, // ปรับความกว้างตามสัดส่วนหน้าจอ (50% ของความกว้างหน้าจอ)
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      // Food name
                      const Text(
                        'ผัดกะเพรา',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      // Destination
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Icon(
                            Icons.location_pin,
                            color: Colors.red,
                          ),
                          SizedBox(width: 5.0),
                          Flexible(
                            child: Text(
                              'จุดหมาย: 123/45 ถนนหลัก, เขตเมือง, ประเทศไทย',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                              overflow:
                                  TextOverflow.ellipsis, // ตัดข้อความถ้ายาวเกิน
                            ),
                          ),
                        ],
                      ),
                      FilledButton(onPressed: () {}, child: Text("รับงาน")),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: RidersGetPage(),
  ));
}
