import 'dart:math';

import 'package:delivery_app/config/config.dart';
import 'package:delivery_app/page/RegisterCustomer.dart';
import 'package:delivery_app/page/Risers_Get.dart';
import 'package:delivery_app/page/User_send.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String textResLogin = "";

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF04DD16), // พื้นหลังสีเขียว
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isLandscape ? mediaQuery.size.width * 0.8 : 335.0,
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Card(
                  margin: const EdgeInsets.only(top: 200.0), // ลดระยะห่าง
                  color: Colors.white
                      .withOpacity(0.7), // ปรับให้โปร่งใสขึ้นเล็กน้อย
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10.0),
                        const Text(
                          'Phone', // เปลี่ยนจาก 'Name' เป็น 'Phone'
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5.0),
                        TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0.5,
                              horizontal: 16.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30.0), // ลดระยะห่าง
                        const Text(
                          'Password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5.0),
                        TextField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0.5,
                              horizontal: 16.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Handle back action
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterCustomer(),
                                    ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.white, // Color of the back button
                                foregroundColor:
                                    const Color.fromRGBO(0, 253, 21, 0.62),
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Round corners of button
                                ),
                              ),
                              child: const Text('Sign-in'),
                            ),
                            const SizedBox(
                                width: 10.0), // เพิ่มระยะห่างระหว่างปุ่ม
                            ElevatedButton(
                              onPressed: () {
                                // Handle login action
                                login();
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromARGB(255, 1, 255, 98),
                                ),
                                foregroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromARGB(255, 255, 255, 255),
                                ),
                                elevation: WidgetStateProperty.all<double>(5.0),
                                shape: WidgetStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                              ),
                              child: const Text('Login'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Text(textResLogin), // สำหรับแสดงผลลัพธ์ของการ Login
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -65.0, // ปรับตำแหน่งโลโก้ให้สูงขึ้นเล็กน้อย
                  child: Image.asset(
                    'assets/images/Logodelivery.png', // โลโก้ Delivery
                    width: 330.0, // ขนาดโลโก้
                    height: 300.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void login() async {
    var config = await Configuration.getConfig();
    var usl = config['apiEndpoint'];
    var model = {};
    String debug = '';
    int type = 1;
    if (usernameController.text != ' ' ||
        passwordController.text != ' ' ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      if (type == 0) {
        http.get(Uri.parse("$usl/"));
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserSendPage(
                id: 1,
              ),
            ));
      } else if (type == 1) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RidersGetPage(),
            ));
      } else {
        setState(() {
          debug = "usernamme or password invalid !!!";
        });
      }
    } else {
      setState(() {
        debug = "username or password in put information";
      });
    }
  }
}
