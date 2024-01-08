import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static Future<void> saveInt(String keyName, int intValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = intValue;
    prefs.setInt(key, value);
    if (kDebugMode) {
      print('saved $value');
    }
  }

  static Future<int> readInt(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = prefs.getInt(key) ?? 0;
    if (kDebugMode) {
      print('read: $value');
    }
    return value;
  }

  static Future<void> saveDouble(String keyName, double doubleValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = doubleValue;
    prefs.setDouble(key, value);
    if (kDebugMode) {
      print('saved $value');
    }
  }

  static Future<double> readDouble(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = prefs.getDouble(key) ?? 0.0;
    if (kDebugMode) {
      print('read: $value');
    }
    return value;
  }

  static Future<void> saveString(String keyName, String stringValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = stringValue;
    prefs.setString(key, value);
    if (kDebugMode) {
      print('saved $value');
    }
  }

  static Future<String> readString(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = prefs.getString(key) ?? '';
    if (kDebugMode) {
      print('read: $value');
    }
    return value;
  }

  static Future<void> saveBool(String keyName, bool boolValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = boolValue;
    prefs.setBool(key, value);
    if (kDebugMode) {
      print('saved $value');
    }
  }

  static Future<bool> readBool(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = prefs.getBool(key) ?? false;
    if (kDebugMode) {
      print('read: $value');
    }
    return value;
  }

  static Future<void> saveStringList(String keyName, List<String> stringListValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = stringListValue;
    prefs.setStringList(key, value);
    if (kDebugMode) {
      print('saved $value');
    }
  }

  static Future<List<String>> readStringList(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = prefs.getStringList(key) ?? <String>[];
    if (kDebugMode) {
      print('read: $value');
    }
    return value;
  }
}
