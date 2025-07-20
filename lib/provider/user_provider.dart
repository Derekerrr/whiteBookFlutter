import 'package:easy_chat/store/login_user_storage.dart';
import 'package:flutter/material.dart';

import '../models/peer_user.dart';

class UserProvider with ChangeNotifier {
  PeerUser? _user;

  // 获取当前用户信息
  PeerUser get user => _user ?? PeerUser(id: -1, nickname: '未知用户'); // 默认值或空用户处理

  // 设置用户信息并通知监听者更新
  set user(PeerUser? user) {
    _user = user;
    _saveUser(user);  // 保存到持久化存储
    notifyListeners();  // 通知监听者
  }

  // 从 shared_preferences 中加载用户信息
  Future<void> loadUser() async {
    try {
      PeerUser? user = await LoginUserStorage.getUser();
      if (user != null) {
        _user = user;
        notifyListeners();
      }
    } catch (e) {
      // 处理错误，比如打印日志或提供默认值
      print('Failed to load user: $e');
    }
  }

  // 将用户信息保存到 shared_preferences 中
  Future<void> _saveUser(PeerUser? user) async {
    if (user != null) {
      LoginUserStorage.saveUser(user);
    }
  }

  // 将用户信息保存到 shared_preferences 中
  Future<void> clear() async {
    _user = null;
    LoginUserStorage.clear();
  }


  // 修改用户信息（例如修改昵称、头像等）
  Future<void> updateUser(PeerUser updatedUser) async {
    _user = updatedUser;
    await _saveUser(updatedUser);
    notifyListeners();  // 通知更新
  }
}
