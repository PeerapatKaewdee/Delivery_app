import 'dart:io';

import 'package:delivery_app/config/config.dart';
import 'package:delivery_app/page/Login.dart';
import 'package:delivery_app/page/RegisterCustomer.dart';
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
                              child: GestureDetector(
                                onTap: () async {
                                  final XFile? pickedImage = await picker
                                      .pickImage(source: ImageSource.gallery);
                                  if (pickedImage != null) {
                                    log(pickedImage.path);
                                    setState(() {
                                      image =
                                          pickedImage; // อัปเดตค่า image ที่เลือก
                                    });
                                  } else {
                                    log('No Image');
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 45, // ขนาดของ avatar
                                  backgroundColor: Colors.grey[300],
                                  child: image !=
                                          null // ถ้า image มีค่า ให้แสดงรูปที่เลือกแทนไอคอน
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
                                          size: 40, // ขนาดไอคอน
                                          color: Colors.white,
                                        ),
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
        log("phonr is null");
        if (licensePlateController.text != '') {
          log("car is null");
          if (passwordController.text != '' &&
              confirmPasswordController.text != '') {
            log("password invalid");
            if (passwordController.text == confirmPasswordController.text) {
              final response = await http.post(
                Uri.parse('$url/register'), // Use the dynamic URL
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'name': usernameController.text,
                  'phone_number': phoneController.text,
                  'license_plate': licensePlateController.text,
                  'password': passwordController.text,
                  'profile_image': '', // Implement image upload logic if needed
                }),
              );

              if (response.statusCode == 201) {
                // Registration successful
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Success'),
                    content: Text('Rider registered successfully!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pop(context); // Go back to previous screen
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              } else if (response.statusCode == 409) {
                // Phone number already exists
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
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
              log("sucess");
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Success'),
                  content: Text('Rider registered successfully!'),
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
                title: Text('Success'),
                content: Text('Rider registered successfully!'),
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
              title: Text('Success'),
              content: Text('Rider registered successfully!'),
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
            title: Text('Success'),
            content: Text('Rider registered successfully!'),
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
          title: Text('Success'),
          content: Text('Rider registered successfully!'),
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
}
