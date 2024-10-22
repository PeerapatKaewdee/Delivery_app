import 'package:delivery_app/config/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:delivery_app/page/User_Map.dart';
import 'package:delivery_app/page/User_List.dart';
import 'package:delivery_app/page/User_Profile.dart'; // นำเข้าหน้านี้

class UserSendPage extends StatefulWidget {
  const UserSendPage({super.key, required this.id});
  final int id;

  @override
  State<UserSendPage> createState() => _UserSendPageState();
}

class _UserSendPageState extends State<UserSendPage> {
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _itemDetailsController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  String url = '';
  int _selectedIndex = 0;
  Map<String, dynamic>? _selectedReceiver;
  List<Map<String, dynamic>> _deliveries = []; // รายการจัดส่ง

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      setState(() {
        url = config['apiEndpoint'];
      });
    });
  }

  Future<void> _searchUser() async {
    final phoneNumber = _receiverPhoneController.text.trim();
    if (phoneNumber.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('$url/search-user'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'phone': phoneNumber,
            'user_id': widget.id,
          }),
        );

        if (response.statusCode == 200) {
          final List<dynamic> jsonResponse = jsonDecode(response.body);
          setState(() {
            _searchResults = jsonResponse.map((user) {
              return {
                'receiver_id': user['receiver_id'],
                'receiver_name': user['receiver_name'],
                'receiver_phone': user['receiver_phone'],
                'is_self': user['receiver_id'] == widget.id,
              };
            }).toList();
          });
        } else {
          setState(() {
            _searchResults = [];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาดในการค้นหา')),
        );
      }
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  Future<void> _createDelivery() async {
    String itemDetails = _itemDetailsController.text.trim();

    if (itemDetails.isNotEmpty) {
      final response = await http.post(
        Uri.parse('$url/create-delivery'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'sender_id': widget.id,
          'receiver_id': _selectedReceiver != null ? _selectedReceiver!['receiver_id'] : null,
          'receiver_phone': _receiverPhoneController.text.isNotEmpty
              ? _receiverPhoneController.text
              : null,
          'items': [
            {
              'description': itemDetails,
              'image': null,
            },
          ],
        }),
      );

      if (response.statusCode == 201) {
        // เพิ่มรายการส่งสินค้าไปยังรายการที่สร้างขึ้น
        setState(() {
          _deliveries.add({
            'description': itemDetails,
            'receiver_name': _selectedReceiver?['receiver_name'] ?? 'ไม่ระบุ',
            'receiver_phone': _receiverPhoneController.text.isNotEmpty ? _receiverPhoneController.text : 'ไม่ระบุ',
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สร้างรายการส่งสินค้าสำเร็จ!')),
        );
        _receiverPhoneController.clear();
        _itemDetailsController.clear();
        _searchResults = [];
        _selectedReceiver = null; // Reset selected receiver
      } else {
        String errorMessage = 'เกิดข้อผิดพลาดในการสร้างรายการ';
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          if (errorResponse['message'] != null) {
            errorMessage = errorResponse['message'];
          }
        } catch (e) {
          // Handle JSON parse error
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
    } else if (index == 3) { // ถ้าเลือกที่ UserProfilePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserProfilePage()),
      );
    }
  }

  void _selectReceiver(Map<String, dynamic> receiver) {
    setState(() {
      _selectedReceiver = receiver;
      _receiverPhoneController.text = receiver['receiver_phone'] ?? '';
      _searchResults = []; // Clear search results
    });
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
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(_searchResults[index]['receiver_name']),
                        subtitle: Text(_searchResults[index]['receiver_phone']),
                        onTap: () {
                          if (_searchResults[index]['is_self']) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('นี่คือเบอร์ของคุณ')),
                            );
                          } else {
                            _selectReceiver(_searchResults[index]);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedReceiver != null) ...[
                const Text(
                  'ผู้รับที่เลือก:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(_selectedReceiver!['receiver_name']),
                    subtitle: Text(_selectedReceiver!['receiver_phone']),
                  ),
                ),
              ],
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
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
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
            icon: Icon(Icons.map),
            label: 'แผนที่',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'รายการ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
