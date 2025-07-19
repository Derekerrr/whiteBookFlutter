import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/peer_user.dart';

class LoginUserStorage {
  static const String _userKey = 'login_user';

  /// 保存用户信息
  static Future<void> saveUser(PeerUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// 获取用户信息（返回 PeerUser）
  static Future<PeerUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr != null) {
      final jsonMap = jsonDecode(jsonStr);
      return PeerUser.fromJson(jsonMap);
    }
    return null;
  }

  /// 获取用户ID
  static Future<int?> getUserId() async {
    final user = await getUser();
    return user?.id;
  }

  /// 获取用户名
  static Future<String?> getUsername() async {
    final user = await getUser();
    return user?.username;
  }

  /// 获取昵称
  static Future<String?> getNickname() async {
    final user = await getUser();
    return user?.nickname;
  }

  /// 清除用户信息（退出登录）
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
