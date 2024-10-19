import 'package:delivery_app/config/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonEncode
import 'dart:developer'; // for log
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

  Future<void> registerRider() async {
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
          content: Text('Failed to register rider. Please try again.'),
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
                Positioned(
                  top: 5,
                  child: Image.asset(
                    'assets/images/motorcycle_rider.png', // Change this path to your logo
                    width: 150,
                    height: 100,
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(top: 110.0),
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
                            onTap: () {
                              // Handle image upload here
                            },
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        const Text('Username',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5.0),
                        TextField(
                          controller: usernameController,
                          style: const TextStyle(fontSize: 14.0),
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        const Text('Phone',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5.0),
                        TextField(
                          controller: phoneController,
                          style: const TextStyle(fontSize: 14.0),
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        const Text('License Plate',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5.0),
                        TextField(
                          controller: licensePlateController,
                          style: const TextStyle(fontSize: 14.0),
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        const Text('Password',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5.0),
                        TextField(
                          controller: passwordController,
                          style: const TextStyle(fontSize: 14.0),
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 10.0),
                        const Text('Confirm Password',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5.0),
                        TextField(
                          controller: confirmPasswordController,
                          style: const TextStyle(fontSize: 14.0),
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
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
                                Navigator.pop(context);
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
                              child: const Text('Back'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                registerRider(); // Call the API
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 253, 21, 0.62),
                                foregroundColor: Colors.white,
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
