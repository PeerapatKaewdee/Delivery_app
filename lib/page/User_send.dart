import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserSendPage extends StatefulWidget {
  const UserSendPage({super.key});

  @override
  State<UserSendPage> createState() => _UserSendPageState();
}

class _UserSendPageState extends State<UserSendPage> {
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _itemDetailsController = TextEditingController();
  XFile? _image; // สำหรับเก็บภาพที่ถ่าย

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    // เปิดกล้องหรือแกลเลอรีเพื่อเลือกรูปภาพ
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image; // เก็บภาพที่เลือก
    });
  }

  void _createDelivery() {
    // ฟังก์ชันสำหรับสร้างรายการส่งสินค้า
    String receiverPhone = _receiverPhoneController.text;
    String itemDetails = _itemDetailsController.text;

    // ตรวจสอบข้อมูลและประมวลผลที่นี่ (เช่นส่งไปยังฐานข้อมูล)
    if (receiverPhone.isNotEmpty && itemDetails.isNotEmpty && _image != null) {
      // ทำการบันทึกข้อมูล
      print('Receiver Phone: $receiverPhone');
      print('Item Details: $itemDetails');
      print('Image Path: ${_image!.path}');
      // สามารถส่งข้อมูลไปยังฐานข้อมูลได้ที่นี่
    } else {
      // แจ้งเตือนให้กรอกข้อมูลให้ครบถ้วน
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างรายการส่งสินค้า'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _receiverPhoneController,
              decoration: const InputDecoration(labelText: 'หมายเลขโทรศัพท์ผู้รับ'),
            ),
            TextField(
              controller: _itemDetailsController,
              decoration: const InputDecoration(labelText: 'รายละเอียดสินค้า'),
            ),
            const SizedBox(height: 16),
            _image == null
                ? const Text('ยังไม่มีรูปภาพ')
                : Image.file(
                    File(_image!.path),
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('ถ่ายรูปประกอบสถานะ'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createDelivery,
              child: const Text('สร้างรายการส่งสินค้า'),
            ),
          ],
        ),
      ),
    );
  }
}
