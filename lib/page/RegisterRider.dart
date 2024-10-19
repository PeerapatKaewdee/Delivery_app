import 'package:delivery_app/config/config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

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

  String url = '';
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      log(value['apiEndpoint']);
      setState(() {
        url = value['apiEndpoint'] ?? '';
      });
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        log('No image selected.');
      }
    });
  }

  Future<void> registerRider() async {
    if (_validateInputs()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      final request = http.MultipartRequest('POST', Uri.parse('$url/register'));

      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', _image!.path),
        );
      }

      request.fields['name'] = usernameController.text;
      request.fields['phone_number'] = phoneController.text;
      request.fields['license_plate'] = licensePlateController.text;
      request.fields['password'] = passwordController.text;

      final response = await request.send();
      setState(() {
        _isLoading = false; // Stop loading
      });

      if (response.statusCode == 201) {
        _showDialog('Success', 'Rider registered successfully!', true);
      } else if (response.statusCode == 409) {
        _showDialog('Error', 'Phone number already exists.', false);
      } else {
        _showDialog('Error', 'Failed to register rider. Please try again.', false);
      }
    }
  }

  bool _validateInputs() {
    if (usernameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        licensePlateController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      _showDialog('Error', 'All fields are required and cannot contain only spaces.', false);
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showDialog('Error', 'Passwords do not match.', false);
      return false;
    }

    // Add more validation checks if needed

    return true;
  }

  void _showDialog(String title, String content, bool goBack) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (goBack) Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    licensePlateController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 330.0),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 5,
                  child: Image.asset(
                    'assets/images/motorcycle_rider.png',
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
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: _image != null ? FileImage(_image!) : null,
                              child: _image == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        buildTextField('Username', usernameController),
                        buildTextField('Phone', phoneController),
                        buildTextField('License Plate', licensePlateController),
                        buildPasswordField('Password', passwordController),
                        buildPasswordField('Confirm Password', confirmPasswordController),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildBackButton(),
                            buildRegisterButton(),
                          ],
                        ),
                        if (_isLoading) const Center(child: CircularProgressIndicator()), // Loading indicator
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

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5.0),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14.0),
          decoration: const InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  Widget buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5.0),
        TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(fontSize: 14.0),
          decoration: const InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  Widget buildBackButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromRGBO(0, 253, 21, 0.62),
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget buildRegisterButton() {
    return ElevatedButton(
      onPressed: registerRider,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(0, 253, 21, 0.62),
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
