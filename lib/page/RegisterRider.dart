import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/config/config.dart';
import 'package:delivery_app/page/Login.dart';
import 'package:delivery_app/page/RegisterCustomer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonEncode
import 'dart:developer';

import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart'; // for log
// Import your configuration file here

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
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String url = ''; // Initialize the URL variable
  LatLng? selectedLocation;
  String address = '';
  final ImagePicker picker = ImagePicker();
  XFile? image;
  @override
  void initState() {
    super.initState();
    // Read the configuration for the API endpoint
    Configuration.getConfig().then((value) {
      // log(value['apiEndpoint']);
      setState(() {
        url = value['apiEndpoint'] ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 330.0, // Adjust maximum width of the card
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Custom logo icon
                Image.asset('assets/images/motorcycle_rider.png'),
                Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.only(
                          top: 100.0), // Margin from top for the card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(
                            20.0), // Padding inside the card
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10.0),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final XFile? pickedImage =
                                          await picker.pickImage(
                                              source: ImageSource.gallery);
                                      if (pickedImage != null) {
                                        log(pickedImage.path);
                                        setState(() {
                                          image =
                                              pickedImage; // อัปเดตรูปที่เลือก
                                        });
                                      } else {
                                        log('No Image');
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: 45, // ขนาดของ avatar
                                      backgroundColor: Colors.grey[300],
                                      child: image != null
                                          ? ClipOval(
                                              child: Image.file(
                                                File(image!.path),
                                                fit: BoxFit.cover,
                                                width: 90,
                                                height: 90,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 40, // ขนาดของไอคอน
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
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
                              style:
                                  const TextStyle(fontSize: 14.0), // Font size
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 10.0), // Spacing
                            const Text(
                              'Phone',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: phoneController,
                              style:
                                  const TextStyle(fontSize: 14.0), // Font size
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0), // Spacing
                            const Text(
                              'ทะเบียนรถ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: licensePlateController,
                              style:
                                  const TextStyle(fontSize: 14.0), // Font size
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0), // Spacing
                            const Text(
                              'Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: passwordController,
                              style:
                                  const TextStyle(fontSize: 14.0), // Font size
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 10.0), // Spacing
                            const Text(
                              'Confirm Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: confirmPasswordController,
                              style:
                                  const TextStyle(fontSize: 14.0), // Font size
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20.0), // Spacing
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Arrange buttons with space in between
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle back action
                                    Navigator.of(context).popUntil(
                                      (route) => route.isFirst,
                                    ); // Navigate back to the previous screen
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                      const Color.fromARGB(255, 255, 255,
                                          255), // Color of the back button
                                    ),
                                    foregroundColor:
                                        WidgetStateProperty.all<Color>(
                                      const Color.fromRGBO(0, 253, 21, 0.62),
                                    ),
                                    elevation:
                                        WidgetStateProperty.all<double>(5.0),
                                    shape:
                                        WidgetStateProperty.all<OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Round corners of button
                                      ),
                                    ),
                                  ),
                                  child: const Text('Back'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    registerRider();
                                    onConfirm;
                                    // Handle register action
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                      const Color.fromARGB(255, 1, 255, 98),
                                    ),
                                    foregroundColor:
                                        WidgetStateProperty.all<Color>(
                                      const Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    elevation:
                                        WidgetStateProperty.all<double>(5.0),
                                    shape:
                                        WidgetStateProperty.all<OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Round corners of button
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
                    SizedBox(
                      height: 60,
                    ),
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
                                  ));
                            },
                            child: Text("Create Acount Users -->"),
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
    log(url.toString());
    log("message");
    log(image.toString());
    if (url.isEmpty) {
      // Show an error if the URL is not set
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('API endpoint is not set. Please try again later.'),
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
    if (usernameController.text != '') {
      if (phoneController.text != '') {
        log("phonr");
        if (licensePlateController.text != '') {
          log("car");
          if (passwordController.text != '' &&
              confirmPasswordController.text != '') {
            log("password");
            if (passwordController.text == confirmPasswordController.text) {
              log("password123");
              http
                  .post(
                Uri.parse('$url/api/rider/register'), // Use the dynamic URL
                headers: {"Content-Type": "application/json; charset=utf-8"},
                body: jsonEncode({
                  'name': usernameController.text,
                  'phone_number': phoneController.text,
                  'license_plate': licensePlateController.text,
                  'password': passwordController.text,
                  'profile_image': '', // Implement image upload logic if needed
                }),
              )
                  .then((value) {
                var jsonResponse = jsonDecode(value.body);
                if (value.statusCode == 200 ||
                    jsonResponse['message'] == "ลงทะเบียนไรเดอร์สำเร็จ") {
                  // Registration successful
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Success'),
                      content: Text('Rider registered successfully!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).popUntil(
                              (route) => route.isFirst,
                            );
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else if (value.statusCode == 409) {
                  // Phone number already exists
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error!!!'),
                      content: Text('Phone number already exists.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Some other error
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content:
                          Text('Failed to register rider. Please try again.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
                log(value.body.toString());
              });
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text(
                      'Failed to register rider, Password does not match!!!!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            }
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Error!!!'),
                content: Text(
                    'Failed to register rider. Please INput PASSWORD !!!.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error!!!'),
              content: Text(
                  'Failed to register rider. Please Input licensePlate!!!.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error!!!'),
            content: Text(
                'Failed to register rider. Please Input PHONE NUMBER !!!.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error!!!'),
          content: Text('Failed to register rider. Please Input Username !!!.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

// Method อัปโหลดรูปไปยัง Firebase Storage
  Future<String?> uploadImageToStorage(XFile image) async {
    try {
      // สร้าง reference ไปยังตำแหน่งที่จะเก็บไฟล์ใน Firebase Storage
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${DateTime.now().toString()}.jpg');

      // อัปโหลดไฟล์ไปยัง Firebase Storage
      UploadTask uploadTask = storageRef.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;

      // รับ URL ของรูปที่อัปโหลดแล้ว
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }

  // Method บันทึก URL ของรูปใน Firestore
  Future<void> saveImageUrlToFirestore(String downloadUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc('user_id').set({
        'profileImageUrl': downloadUrl,
      });
      log('Image URL saved to Firestore');
    } catch (e) {
      log('Error saving image URL: $e');
    }
  }

  // เมื่อกดปุ่มยืนยัน
  Future<void> onConfirm() async {
    if (image != null) {
      // 1. อัปโหลดรูปไป Firebase Storage
      String? downloadUrl = await uploadImageToStorage(image!);

      if (downloadUrl != null) {
        // 2. บันทึก URL ลง Firestore
        await saveImageUrlToFirestore(downloadUrl);
      }
    } else {
      log('No image selected');
    }
  }
}
