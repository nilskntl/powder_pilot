import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A utility class for working with shared preferences.
class SharedPref {
  /// Saves an integer value to SharedPreferences.
  ///
  /// @param keyName The key under which the integer value will be stored.
  /// @param intValue The integer value to be stored.
  /// @return A Future that completes with no result once the value is saved.
  static Future<void> saveInt(String keyName, int intValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = intValue;
    prefs.setInt(key, value);
    if (kDebugMode) {
      print('saved $value');
    }
  }

  /// Reads an integer value from SharedPreferences.
  ///
  /// @param keyName The key under which the integer value is stored.
  /// @return A Future that completes with the stored integer value, defaulting to 0 if not found.
  static Future<int> readInt(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = prefs.getInt(key) ?? 0;
    if (kDebugMode) {
      print('read: $value');
    }
    return value;
  }

  /// Saves a double value to SharedPreferences.
  ///
  /// @param keyName The key under which the double value will be stored.
  /// @param doubleValue The double value to be stored.
  /// @return A Future that completes with no result once the value is saved.
  static Future<void> saveDouble(String keyName, double doubleValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = doubleValue;
    prefs.setDouble(key, value);
    if (kDebugMode) {
      print('saved $value');
    }
  }

  /// Reads a double value from SharedPreferences.
  ///
  /// @param keyName The key under which the double value is stored.
  /// @return A Future that completes with the stored double value, defaulting to 0.0 if not found.
  static Future<double> readDouble(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = prefs.getDouble(key) ?? 0.0;
    if (kDebugMode) {
      print('read: $value');
    }
    return value;
  }

  /// Saves a string value to SharedPreferences.
  ///
  /// @param keyName The key under which the string value will be stored.
  /// @param stringValue The string value to be stored.
  /// @return A Future that completes with no result once the value is saved.
  static Future<void> saveString(String keyName, String stringValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = stringValue;
    prefs.setString(key, value);
    if (kDebugMode) {
      print('saved $value');
    }
  }

  /// Reads a string value from SharedPreferences.
  ///
  /// @param keyName The key under which the string value is stored.
  /// @return A Future that completes with the stored string value, defaulting to an empty string if not found.
  static Future<String> readString(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = prefs.getString(key) ?? '';
    if (kDebugMode) {
      print('read: $value');
    }
    return value;
  }

  /// Saves a boolean value to SharedPreferences.
  ///
  /// @param keyName The key under which the boolean value will be stored.
  /// @param boolValue The boolean value to be stored.
  /// @return A Future that completes with no result once the value is saved.
  static Future<void> saveBool(String keyName, bool boolValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = boolValue;
    prefs.setBool(key, value);
    if (kDebugMode) {
      print('saved $value');
    }
  }

  /// Reads a boolean value from SharedPreferences.
  ///
  /// @param keyName The key under which the boolean value is stored.
  /// @return A Future that completes with the stored boolean value, defaulting to false if not found.
  static Future<bool> readBool(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = prefs.getBool(key) ?? false;
    if (kDebugMode) {
      print('read: $value');
    }
    return value;
  }

  /// Saves a list of strings to SharedPreferences.
  ///
  /// @param keyName The key under which the list of strings will be stored.
  /// @param stringListValue The list of strings to be stored.
  /// @return A Future that completes with no result once the value is saved.
  static Future<void> saveStringList(
      String keyName, List<String> stringListValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyName;
    final value = stringListValue;
    prefs.setStringList(key, value);
    if (kDebugMode) {
      print('saved $value');
    }
  }

  /// Reads a list of strings from SharedPreferences.
  ///
  /// @param keyName The key under which the list of strings is stored.
  /// @return A Future that completes with the stored list of strings, defaulting to an empty list if not found.
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
