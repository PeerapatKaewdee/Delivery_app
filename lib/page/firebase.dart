import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class FilebasePage extends StatefulWidget {
  const FilebasePage({super.key});

  @override
  State<FilebasePage> createState() => _FilebasePageState();
}

class _FilebasePageState extends State<FilebasePage> {
  late StreamSubscription? listener;
  var db = FirebaseFirestore.instance;

  TextEditingController docCtl = TextEditingController();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController messageCtl = TextEditingController();
  // TextEditingController docCtl=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        stopRealTime;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            const Text('Document'),
            TextField(
              controller: docCtl,
            ),
            const Text('Name'),
            TextField(
              controller: nameCtl,
            ),
            const Text('Message'),
            TextField(
              controller: messageCtl,
            ),
            FilledButton(
                onPressed: () {
                  var db = FirebaseFirestore.instance;

                  var data = {
                    'name': nameCtl.text,
                    'message': messageCtl.text,
                    'createAt': DateTime.timestamp()
                  };

                  db.collection('inbox').doc('$docCtl').set(data);
                },
                child: const Text('Add Data')),
            FilledButton(
                onPressed: () {
                  readData();
                  // var db = FirebaseFirestore.instance;

                  // var data = {
                  //   'name': nameCtl.text,
                  //   'message': messageCtl.text,
                  //   'createAt': DateTime.timestamp()
                  // };

                  // db.collection('inbox').doc('Room1234').set(data);
                },
                child: const Text('Read Data')),
            FilledButton(onPressed: queryData, child: Text("query Data")),
            FilledButton(
                onPressed: startRealtimeGet,
                child: const Text('Start Real-time Get')),
            FilledButton(
                onPressed: stopRealTime,
                child: const Text('Stop Real-time Get')),
          ],
        ),
      ),
    );
  }

  void readData() async {
    var result = await db.collection('inbox').doc(docCtl.text).get();
    var data = result.data();
    log(data!['message']);
    log((data['createAt'] as Timestamp).millisecondsSinceEpoch.toString());
  }

  void queryData() async {
    var inboxRef = db.collection("inbox");
    var query = inboxRef.where("name", isEqualTo: nameCtl.text);
    var result = await query.get();
    if (result.docs.isNotEmpty) {
      log(result.docs.first.data()['message']);
    }
  }

  void startRealtimeGet() {
    final docRef = db.collection("inbox").doc(docCtl.text);
    listener = docRef.snapshots().listen(
      (event) {
        var data = event.data();
        Get.snackbar(data!['name'].toString(), data['message'].toString());
        log("current data: ${event.data()}");
      },
      onError: (error) => log("Listen failed: $error"),
    );
  }

  void stopRealTime() {
    if (listener != null) {
      listener!.cancel();
    }
  }
}
