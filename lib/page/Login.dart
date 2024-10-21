import 'dart:convert';
import 'package:delivery_app/config/config.dart';
import 'package:delivery_app/page/RegisterCustomer.dart';
import 'package:delivery_app/page/Risers_Get.dart';
import 'package:delivery_app/page/User_send.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
                          obscureText: true,
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
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to the registration page
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
                              child: const Text('Sign Up'), // Registration button
                            ),
                            const SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: () {
                                // Handle login action
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
                          style: const TextStyle(color: Colors.red), // Show login response in red
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

    print('Request: ${jsonEncode(loginRequest)}'); // Debugging line

    try {
      final response = await http.post(
        Uri.parse('$url/api/auth/login'), // Use the correct API URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(loginRequest),
      );

      print('Response status: ${response.statusCode}'); // Debugging line
      print('Response body: ${response.body}'); // Debugging line

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        int id = jsonResponse['id']; // Extract the ID from the response
        String userType = jsonResponse['type'];

        if (userType == 'user') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserSendPage(id: id), // Pass user ID
            ),
          );
        } else if (userType == 'rider') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RidersGetPage(id: id), // Pass rider ID
            ),
          );
        }
      } else {
        setState(() {
          textResLogin = "Invalid credentials. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        textResLogin = "An error occurred: $e";
      });
    }
  }
}
