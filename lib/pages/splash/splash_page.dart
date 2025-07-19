import 'package:easy_chat/store/token_storage.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _checkTokenValidity();
  }

  // 检查 token 是否有效
  Future<void> _checkTokenValidity() async {
    final token = await TokenStorage.getToken();

    if (token == null || !await AuthService.checkTokenValid(token)) {
      // 跳转到登录页面
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',     // 目标路由名
              (route) => false, // 移除所有旧路由
        );
      }
    } else {
      // 跳转到主页
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/main',     // 目标路由名
              (route) => false, // 移除所有旧路由
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // 页面加载时显示加载指示器
      ),
    );
  }
}
