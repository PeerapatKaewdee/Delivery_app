import 'package:delivery_app/page/Selecttype.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/page/Login.dart';
import 'package:delivery_app/page/RegisterCustomer.dart';
import 'package:delivery_app/page/RegisterRider.dart';
import 'package:delivery_app/page/Selecttype.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      //home: LoginPage(),
      //home : RegisterRider()
      // home: RegisterCustomer()
      home:Selecttype(),
   );
  }
}
