import 'dart:convert';
import 'package:delivery_app/page/Risers_Get.dart';
import 'package:delivery_app/page/User_send.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/config/config.dart';
import 'package:delivery_app/page/RegisterCustomer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String textResLogin = "";
  String url = '';
  bool _obscurePassword = true; // ตัวแปรเพื่อควบคุมการเปิด/ปิดตา

  @override
  void initState() {
    super.initState();
    // Load the configuration to get the API URL
    Configuration.getConfig().then((config) {
      setState(() {
        url = config['apiEndpoint']; // Make sure the correct URL is set
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF04DD16), // Green background
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
                  margin: const EdgeInsets.only(top: 200.0),
                  color: Colors.white.withOpacity(0.7),
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
                          'Phone',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5.0),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
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
                        const SizedBox(height: 30.0),
                        const Text(
                          'Password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5.0),
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword, // ใช้ตัวแปรนี้ควบคุม
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0.5,
                              horizontal: 16.0,
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword; // เปลี่ยนสถานะเปิด/ปิดตา
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterCustomer(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor:
                                    const Color.fromRGBO(0, 253, 21, 0.62),
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              child: const Text('Sign Up'),
                            ),
                            const SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: () {
                                login();
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 1, 255, 98),
                                ),
                                foregroundColor: MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 255, 255, 255),
                                ),
                                elevation: MaterialStateProperty.all<double>(5.0),
                                shape: MaterialStateProperty.all<OutlinedBorder>(
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
                        Text(
                          textResLogin,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -65.0,
                  child: Image.asset(
                    'assets/images/Logodelivery.png',
                    width: 330.0,
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
    if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        textResLogin = "Phone number and password cannot be empty.";
      });
      return;
    }

    var loginRequest = {
      'phone_number': phoneController.text.trim(),
      'password': passwordController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse('$url/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(loginRequest),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        int id = jsonResponse['id'];
        String userType = jsonResponse['type'];

        if (userType == 'rider') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RidersGetPage(id: id),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserSendPage(id: id),
            ),
          );
        }
      } else {
        print('Error response: ${response.body}');
        setState(() {
          textResLogin = "Login failed: ${response.reasonPhrase} (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        textResLogin = "An error occurred: $e";
      });
    }
  }
}
