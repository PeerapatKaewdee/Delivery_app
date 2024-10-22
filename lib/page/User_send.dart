import 'package:delivery_app/config/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:delivery_app/page/User_Map.dart'; // Import UserMapPage
import 'package:delivery_app/page/User_List.dart'; // Import UserListPage

class UserSendPage extends StatefulWidget {
  const UserSendPage({super.key, required this.id});
  final int id; // Assume this id is the user ID from login

  @override
  State<UserSendPage> createState() => _UserSendPageState();
}

class _UserSendPageState extends State<UserSendPage> {
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _itemDetailsController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = []; // List to hold search results
  String url = ''; // Variable to hold the API endpoint

  int _selectedIndex = 0; // Store the status of Bottom Navigation

  @override
  void initState() {
    super.initState();
    // Load the API configuration
    Configuration.getConfig().then((config) {
      setState(() {
        url = config['apiEndpoint']; // Set the API endpoint
      });
    });
  }

  Future<void> _searchUser() async {
    final phoneNumber = _receiverPhoneController.text;
    if (phoneNumber.isNotEmpty) {
      final response = await http.post(
        Uri.parse('$url/search-user'), // Change to POST
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'phone': phoneNumber, // Send phone number in the request body
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          _searchResults = jsonResponse
              .map((user) => {
                    'receiver_id': user['receiver_id'],
                    'receiver_name': user['receiver_name'],
                    'receiver_phone': user['receiver_phone'], // Add phone number to the results
                  })
              .toList();
        });
      } else {
        setState(() {
          _searchResults = []; // Clear results if an error occurs
        });
      }
    } else {
      setState(() {
        _searchResults = []; // Clear results if phone number is empty
      });
    }
  }

  Future<void> _createDelivery() async {
    String itemDetails = _itemDetailsController.text;

    // Check that item details are provided
    if (itemDetails.isNotEmpty) {
      final response = await http.post(
        Uri.parse('$url/create-delivery'), // Use the dynamic URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'sender_id': widget.id, // Include sender ID
          'receiver_phone': _receiverPhoneController.text.isNotEmpty
              ? _receiverPhoneController.text
              : null, // Optionally include receiver phone
          'items': [
            {
              'description': itemDetails,
              'image': null, // You can add image URL if needed
            },
          ],
        }),
      );

      if (response.statusCode == 201) {
        // Delivery created successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สร้างรายการส่งสินค้าสำเร็จ!')),
        );
        // Clear inputs after successful creation
        _receiverPhoneController.clear();
        _itemDetailsController.clear();
        _searchResults = []; // Clear search results
      } else {
        // Handle error based on response
        String errorMessage = 'เกิดข้อผิดพลาดในการสร้างรายการ';
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          if (errorResponse['message'] != null) {
            errorMessage = errorResponse['message'];
          }
        } catch (e) {
          // Handle JSON decoding error if necessary
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกรายละเอียดสินค้า')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserMapPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserListPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างรายการส่งสินค้า'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'ค้นหาผู้รับ (ไม่บังคับ)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _receiverPhoneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'หมายเลขโทรศัพท์ผู้รับ (ไม่บังคับ)',
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _searchUser,
                child: const Text('ค้นหา'),
              ),
              const SizedBox(height: 16),
              // List of search results
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_searchResults[index]['receiver_name']),
                      subtitle: Text(_searchResults[index]['receiver_phone']),
                      onTap: () {
                        // Check if the selected user is the sender
                        if (_searchResults[index]['receiver_id'] == widget.id) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ไม่สามารถส่งของให้ตนเอง')),
                          );
                        } else {
                          // Set selected receiver
                          _receiverPhoneController.text = _searchResults[index]['receiver_phone'] ?? '';
                          setState(() {
                            _searchResults = []; // Clear results after selection
                          });
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'สร้างรายการส่งสินค้า',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _itemDetailsController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'รายละเอียดสินค้า',
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: _createDelivery,
                child: const Text('สร้างรายการส่งสินค้า'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.move_to_inbox),
            label: 'รายการส่ง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'ประวัติ',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
