import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/page/Riders_Map.dart';
import 'package:flutter/material.dart';

class RidersGetPage extends StatefulWidget {
  int id = 0;
  RidersGetPage({super.key, required id});

  @override
  State<RidersGetPage> createState() => _RidersGetPageState();
}

class _RidersGetPageState extends State<RidersGetPage> {
  String? selectedDocId; // ตัวแปรเก็บ ID ของเอกสารที่เลือก

  Future<void> updateRiderInfo(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Delivery')
          .doc(docId)
          .update({
        'license_plate': 'ABC1234', // ใส่เลขทะเบียนที่ต้องการ
        'riderLocation':
            GeoPoint(13.7563, 100.5018), // ตัวอย่างตำแหน่งปัจจุบัน (พิกัด)
        'rider_id': 'rider_001', // ID ของไรเดอร์
        'rider_status': 1, // สถานะไรเดอร์
      });
      print('ข้อมูลไรเดอร์ถูกอัปเดตเรียบร้อยแล้ว');
      log(docId.toString());
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RidersMapPage(
              id: widget.id,
              docId: docId,
            ),
          ));
    } catch (e) {
      print('เกิดข้อผิดพลาดในการอัปเดตข้อมูล: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'หน้าแรก',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('Delivery').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('ไม่มีข้อมูลรายการส่งสินค้า'));
              }

              final items = snapshot.data!.docs;

              return Column(
                children: items.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final docId = doc.id; // รับ ID ของเอกสาร

                  return Card(
                    color: const Color.fromARGB(255, 0, 222, 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 4.0,
                    margin: const EdgeInsets.all(15.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10.0),
                          // ตรวจสอบ URL รูปภาพและแสดงไอคอนถ้าไม่มี
                          data['imageUrl'] != null &&
                                  data['imageUrl']!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image.network(
                                    data['imageUrl']!,
                                    height: screenSize.height * 0.10,
                                    width: screenSize.width * 0.5,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.image,
                                  size: screenSize.height * 0.10,
                                  color: Colors.grey, // สีของไอคอน
                                ),
                          const SizedBox(height: 10.0),
                          Text(
                            data['item_details'] ?? 'ไม่ระบุชื่ออาหาร',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_pin,
                                color: Colors.red,
                              ),
                              SizedBox(width: 5.0),
                              Flexible(
                                child: Text(
                                  'จุดหมาย: ${data['riderLocation'] != null ? "Lat: ${data['riderLocation'].latitude}, Long: ${data['riderLocation'].longitude}" : 'ไม่ระบุตำแหน่ง'}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                selectedDocId =
                                    docId; // เก็บ ID ของเอกสารที่เลือก
                              });
                              updateRiderInfo(
                                  docId); // เรียกฟังก์ชันอัปเดตข้อมูล
                            },
                            child: const Text("รับงาน"),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
