import 'package:flutter/material.dart';
import 'package:delivery_app/page/Login.dart';
import 'package:delivery_app/page/RegisterCustomer.dart';
import 'package:delivery_app/page/RegisterRider.dart';

class Selecttype extends StatefulWidget {
  const Selecttype({super.key});

  @override
  State<Selecttype> createState() => _SelecttypeState();
}

class _SelecttypeState extends State<Selecttype> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF64DD17)], // เพิ่ม gradient สีเขียวสดใส
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // จัดให้อยู่ตรงกลาง
          children: [
            // โลโก้พร้อมการตกแต่ง
            Container(
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: const Offset(0, 5), // เงาด้านล่าง
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF00BFA5), // สีพื้นหลังที่เข้ากับพื้นหลังหลักของแอป
                backgroundImage: const AssetImage('assets/images/Logodelivery.png'),
                radius: 100, // ขนาดโลโก้เป็นวงกลม
              ),
            ),
            const SizedBox(height: 20),
            // ปุ่มไปหน้า loginpage
            _buildGradientButton(
              context,
              icon: Icons.login,
              text: 'Login',
              gradientColors: [Colors.blue, Colors.purple],
              destination: const LoginPage(),
            ),
            const SizedBox(height: 20),
            // ปุ่มไปหน้า register customer
            _buildGradientButton(
              context,
              icon: Icons.person_add,
              text: 'Register Customer',
              gradientColors: [Colors.orange, Colors.red],
              destination: const RegisterCustomer(),
            ),
            const SizedBox(height: 20),
            // ปุ่มไปหน้า register rider
            _buildGradientButton(
              context,
              icon: Icons.motorcycle,
              text: 'Register Rider',
              gradientColors: [Colors.green, Colors.teal],
              destination: const RegisterRider(),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างปุ่มแบบ gradient และกำหนดความกว้างให้เท่ากัน
  Widget _buildGradientButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required List<Color> gradientColors,
        required Widget destination,
      }) {
    return Container(
      width: 300, // กำหนดความกว้างของปุ่มให้เท่ากัน
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4), // เงาด้านล่าง
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15), // ลด padding แนวนอนเพื่อปรับความยาวปุ่ม
          backgroundColor: Colors.transparent, // ทำให้ปุ่มโปร่งใสเพื่อให้เห็น gradient
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: Icon(icon, size: 30, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
