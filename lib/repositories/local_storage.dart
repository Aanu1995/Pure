import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/global_utils.dart';

abstract class LocalStorage {
  Future<String?> getStringData(String key);
  Future<bool> saveStringData(String key, String value);
  Future<bool> saveBoolData(String key, bool value);
  Future<bool?> getBoolData(String key);
  Future<bool> clear();
  Future<Map<String, dynamic>?> getUserData();
  Future<void> saveUserData(Map<String, dynamic> data);
  Future<dynamic> getData(String key);
  Future<void> saveData(String key, dynamic data);
}

class LocalStorageImpl implements LocalStorage {
  @override
  Future<bool> saveStringData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  @override
  Future<bool> saveBoolData(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  @override
  Future<String?> getStringData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<bool?> getBoolData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  @override
  Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    return saveBoolData(GlobalUtils.onBoardingSharedPrefKey, true);
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final stringData = await getStringData(GlobalUtils.userSharedPrefKey);
    if (stringData != null && stringData.isNotEmpty) {
      return json.decode(stringData) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> data) async {
    await saveStringData(GlobalUtils.userSharedPrefKey, json.encode(data));
  }

  @override
  Future<dynamic> getData(String key) async {
    final stringData = await getStringData(key);
    if (stringData != null && stringData.isNotEmpty) {
      return json.decode(stringData);
    }
    return null;
  }

  @override
  Future<void> saveData(String key, dynamic data) async {
    await saveStringData(key, json.encode(data));
  }
}
