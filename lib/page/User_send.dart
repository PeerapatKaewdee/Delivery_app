import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/config/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:delivery_app/page/User_Map.dart';
import 'package:delivery_app/page/User_List.dart';
import 'package:delivery_app/page/User_Profile.dart';

class UserSendPage extends StatefulWidget {
  const UserSendPage({super.key, required this.id});
  final int id;

  @override
  State<UserSendPage> createState() => _UserSendPageState();
}

class _UserSendPageState extends State<UserSendPage> {
  final TextEditingController _receiverPhoneController =
      TextEditingController();
  final TextEditingController _itemDetailsController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  String url = '';
  int _selectedIndex = 0; // ตั้งค่าเริ่มต้นให้ไฮไลต์ที่หน้าแรก
  Map<String, dynamic>? _selectedReceiver;
  List<Map<String, dynamic>> _deliveries = [];

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
                'gps_location': user['gps_location'], // เก็บพิกัด GPS ถ้ามี
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
          'receiver_id': _selectedReceiver != null
              ? _selectedReceiver!['receiver_id']
              : null,
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
        setState(() {
          _deliveries.add({
            'description': itemDetails,
            'receiver_name': _selectedReceiver?['receiver_name'] ?? 'ไม่ระบุ',
            'receiver_phone': _receiverPhoneController.text.isNotEmpty
                ? _receiverPhoneController.text
                : 'ไม่ระบุ',
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สร้างรายการส่งสินค้าสำเร็จ!')),
        );
        _receiverPhoneController.clear();
        _itemDetailsController.clear();
        _searchResults = [];
        _selectedReceiver = null;
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

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserSendPage(id: widget.id)),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UserMapPage(
                  id: widget.id,
                )),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UserListPage(
                  id: widget.id,
                )),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UserProfilePage(
                  id: widget.id,
                )),
      );
    }
  }

  void _selectReceiver(Map<String, dynamic> receiver) {
    setState(() {
      _selectedReceiver = receiver;
      _receiverPhoneController.text = receiver['receiver_phone'] ?? '';
      _searchResults = [];
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
                'ค้นหาผู้รับ',
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
                    hintText: 'หมายเลขโทรศัพท์ผู้รับ',
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final receiver = _searchResults[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(receiver['receiver_name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(receiver['receiver_phone']),
                          if (receiver.containsKey('gps_location'))
                            Text(
                              'พิกัด: Lat: ${receiver['gps_location']['lat']}, Lng: ${receiver['gps_location']['lng']}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                      onTap: () {
                        if (receiver['is_self']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('นี่คือเบอร์ของคุณ')),
                          );
                        } else {
                          _selectReceiver(receiver);
                        }
                      },
                    ),
                  );
                },
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedReceiver!['receiver_phone']),
                        if (_selectedReceiver!.containsKey('gps_location'))
                          Text(
                            'พิกัด: Lat: ${_selectedReceiver!['gps_location']['lat']}, Lng: ${_selectedReceiver!['gps_location']['lng']}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _selectedReceiver = null; // ลบผู้รับที่เลือก
                        });
                      },
                    ),
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
                onPressed: sendShipment,
                child: const Text('สร้างรายการ'),
              ),
              const SizedBox(height: 16),
              // const Text(
              //   'รายการส่งสินค้า:',
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              // ),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: _deliveries.length,
              //     itemBuilder: (context, index) {
              //       return Card(
              //         margin: const EdgeInsets.symmetric(vertical: 8.0),
              //         child: ListTile(
              //           title: Text(_deliveries[index]['description']),
              //           subtitle: Text(
              //               'ผู้รับ: ${_deliveries[index]['receiver_name']} - โทร: ${_deliveries[index]['receiver_phone']}'),
              //           trailing: IconButton(
              //             icon: const Icon(Icons.delete),
              //             onPressed: () {
              //               setState(() {
              //                 _deliveries.removeAt(index); // ลบรายการที่เลือก
              //               });
              //               ScaffoldMessenger.of(context).showSnackBar(
              //                 const SnackBar(
              //                     content:
              //                         Text('ลบรายการส่งสินค้าเรียบร้อยแล้ว')),
              //               );
              //             },
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
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
            label: 'รายการรับ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }

  void sendShipment() {
    var db = FirebaseFirestore.instance;
    var itemDetails = _itemDetailsController.text.trim();

    // ตรวจสอบว่าได้เลือกผู้รับหรือไม่
    if (_selectedReceiver != null &&
        _selectedReceiver!['gps_location'] != null) {
      var data = {
        "send_id": widget.id,
        "reship_id": _selectedReceiver!['receiver_id'],
        'rider_id': 0,
        'receiver_phone': _selectedReceiver!['receiver_phone'],
        'item_details': itemDetails,
        'reshiplocation': {
          'lat': _selectedReceiver!['gps_location']['lat'],
          'lng': _selectedReceiver!['gps_location']['lng'],
        },
      };

      // บันทึกข้อมูลไปยัง Firestore โดยใช้ add เพื่อสร้าง ID อัตโนมัติ
      db.collection('Delivery').add(data).then((docRef) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ข้อมูลการส่งถูกบันทึกเรียบร้อยแล้ว')),
        );
        print('Shipment data sent successfully with ID: ${docRef.id}');
        log(docRef.id);
      }).catchError((error) {
        print('Failed to send shipment data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
        );
      });
    } else {
      // ถ้าไม่ได้เลือกผู้รับหรือ gps_location เป็น null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('กรุณาเลือกผู้รับและตรวจสอบตำแหน่ง GPS ก่อนส่ง')),
      );
    }
  }
}
