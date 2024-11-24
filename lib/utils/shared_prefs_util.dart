import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtil {
  static const String _cartPrefix = 'cart_';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveCartToPreferences(int userId, List<Map<String, dynamic>> cartList) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode(cartList);
    await prefs.setString('$_cartPrefix$userId', cartJson);
  }

  Future<List<Map<String, dynamic>>> loadCartFromPreferences(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('$_cartPrefix$userId');
    if (cartJson == null) return [];

    try {
      final List<dynamic> decodedList = json.decode(cartJson);
      return List<Map<String, dynamic>>.from(decodedList);
    } catch (e) {
      return [];
    }
  }

  Future<void> clearCartPreferences(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cartPrefix$userId');
  }
}