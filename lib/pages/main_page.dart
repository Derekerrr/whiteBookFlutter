import 'package:easy_chat/pages/post/do_post_page.dart';
import 'package:easy_chat/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_chat/provider/conversation_provider.dart';

import '../provider/user_provider.dart';
import '../services/auth_service.dart';
import '../services/websocket_manager.dart';
import '../store/token_storage.dart';
import 'conversation/conversation_page.dart';
import 'home/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkTokenValidity();
    // 初始化全局用户变量
    context.read<UserProvider>().loadUser();
    // 初始化websocket
    WebSocketManager().connect();
    // 初始化会话信息
    context.read<ConversationProvider>().loadConversations();
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
    }
  }

  // 直接使用 StatefulWidget 使得页面状态可以保留
  final List<Widget> _pages = [
    const HomePage(),
    const PublishPostPage(), // 后续可换成发布页面
    const ConversationPage(),
    const ProfilePage(), // 后续可换成个人页
  ];

  void navigatePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<ConversationProvider>().totalUnreadCount; // 获取未读消息总数

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => navigatePage(index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: '发布',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none, // 允许子元素溢出
              children: [
                Icon(Icons.chat),
                if (unreadCount > 0)
                  Positioned(
                    right: -12,
                    top: -8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
