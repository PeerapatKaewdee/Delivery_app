import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/firebase_options.dart';
import 'package:delivery_app/page/Risers_Get.dart';
import 'package:delivery_app/page/Selecttype.dart';
import 'package:delivery_app/page/User_send.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/page/Login.dart';
import 'package:delivery_app/page/RegisterCustomer.dart';
import 'package:delivery_app/page/RegisterRider.dart';
import 'package:delivery_app/page/Selecttype.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Connnect to FireStore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
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
      // home:Selecttype(),
      // home: LoginPage(),
      home: RidersGetPage(id: 1),
    );
  }
}
