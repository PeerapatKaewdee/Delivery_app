import 'package:flutter/services.dart';
import 'dart:convert';

class Configuration {
  static Future<Map<String, dynamic>> getConfig() {
    return rootBundle.loadString('assets/config/config.json').then(
          (value) => jsonDecode(value) as Map<String, dynamic>,
        );
  }
}