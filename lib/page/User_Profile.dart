import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์ผู้ใช้'),
      ),
      body: Center(
        child: const Text(
          'นี่คือหน้าประวัติส่วนตัว',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
