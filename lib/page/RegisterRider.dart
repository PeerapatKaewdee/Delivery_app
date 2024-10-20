import 'package:delivery_app/config/config.dart';
import 'package:delivery_app/model/request/RiderPostReg.dart';

import 'package:delivery_app/page/Login.dart';
import 'package:delivery_app/page/RegisterCustomer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonEncode
import 'dart:developer'; // for log
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // สำหรับการใช้ File

class RegisterRider extends StatefulWidget {
  const RegisterRider({super.key});

  @override
  State<RegisterRider> createState() => _RegisterRiderState();
}

class _RegisterRiderState extends State<RegisterRider> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController licensePlateController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String url = ''; // Initialize the URL variable
  String profileImagePath = ''; // ตัวแปรเก็บที่อยู่ของภาพ

  @override
  void initState() {
    super.initState();
    // Read the configuration for the API endpoint
    Configuration.getConfig().then((value) {
      log(value['apiEndpoint']);
      setState(() {
        url = value['apiEndpoint'] ?? '';
      });
    });
  }

  // ฟังก์ชันสำหรับเลือกภาพ
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImagePath = pickedFile.path; // เก็บที่อยู่ของภาพที่เลือก
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 330.0,
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Image.asset('assets/images/motorcycle_rider.png'),
                Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.only(top: 100.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10.0),
                            Center(
                              child: GestureDetector(
                                onTap: pickImage, // เรียกฟังก์ชันที่สร้างขึ้นเมื่อกด
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: profileImagePath.isNotEmpty
                                      ? FileImage(File(profileImagePath)) // แสดงภาพที่เลือก
                                      : null,
                                  child: profileImagePath.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Username',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: usernameController,
                              style: const TextStyle(fontSize: 14.0),
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Phone',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: phoneController,
                              style: const TextStyle(fontSize: 14.0),
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'License Plate',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: licensePlateController,
                              style: const TextStyle(fontSize: 14.0),
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: passwordController,
                              style: const TextStyle(fontSize: 14.0),
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Confirm Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: confirmPasswordController,
                              style: const TextStyle(fontSize: 14.0),
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
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
                                    Navigator.of(context).popUntil(
                                      (route) => route.isFirst,
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                      const Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    foregroundColor: MaterialStateProperty.all<Color>(
                                      const Color.fromRGBO(0, 253, 21, 0.62),
                                    ),
                                    elevation: MaterialStateProperty.all<double>(5.0),
                                    shape: MaterialStateProperty.all<OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                    ),
                                  ),
                                  child: const Text('Back'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    registerRider();
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
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                    ),
                                  ),
                                  child: const Text('Register'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 60),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterCustomer(),
                                ),
                              );
                            },
                            child: Text("Create Account Users -->"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> registerRider() async {
    if (url.isEmpty) {
      // Show an error if the URL is not set
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('API endpoint not configured.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      // Show an error if passwords don't match
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Passwords do not match.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Create the RiderPostReg object
    RiderPostReg rider = RiderPostReg(
      phoneNumber: phoneController.text,
      password: passwordController.text,
      name: usernameController.text,
      profileImage: profileImagePath,
      licensePlate: licensePlateController.text,
    );

    final response = await http.post(
      Uri.parse('$url/riders'),
      headers: {'Content-Type': 'application/json'},
      body: riderPostRegToJson(rider), // Use the model to serialize
    );

    if (response.statusCode == 201) {
      // Navigate to the Login page if registration is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } else {
      // Show an error if registration failed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Registration failed. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
