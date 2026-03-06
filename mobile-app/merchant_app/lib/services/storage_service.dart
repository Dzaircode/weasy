import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/merchant_model.dart';

class StorageService {
  // ── Token ────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kTokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kTokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kTokenKey);
  }

  // ── Merchant ─────────────────────────────────────────────
  static Future<void> saveMerchant(MerchantModel merchant) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kMerchantKey, jsonEncode(merchant.toJson()));
  }

  static Future<MerchantModel?> getMerchant() async {
    final prefs = await SharedPreferences.getInstance();
    final data  = prefs.getString(kMerchantKey);
    if (data == null) return null;
    return MerchantModel.fromJson(jsonDecode(data));
  }

  // ── Logout ───────────────────────────────────────────────
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Helper ───────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}