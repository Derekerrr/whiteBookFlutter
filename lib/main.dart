import 'package:easy_chat/provider/conversation_provider.dart';
import 'package:easy_chat/provider/post_provider.dart';
import 'package:easy_chat/provider/user_provider.dart';
import 'package:easy_chat/services/websocket_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:easy_chat/pages/home/home_page.dart';
import 'package:easy_chat/pages/main_page.dart';
import 'package:easy_chat/pages/register/step_username.dart';
import 'package:easy_chat/pages/splash/splash_page.dart';
import 'package:easy_chat/pages/login/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ConversationProvider()),
    ],
    child: WhiteBookApp(),
  ),);
}

class WhiteBookApp extends StatelessWidget {
  const WhiteBookApp({super.key});

  @override

  Widget build(BuildContext context) {
    // 初始化WebSocketManager，用户全局会话列表的监控
    WebSocketManager().init( Provider.of<ConversationProvider>(context, listen: false));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
          child: const WhiteBookApp(),
        ),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        // ChangeNotifierProvider(create: (_) => ConversationProvider())
      ],
      child: MaterialApp(
        title: 'WhiteBook',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white,
        ),
        routes: {
          '/main': (context) => const MainPage(),
          '/home': (context) => const HomePage(),
          '/register': (context) => StepUsernamePage(),
          '/login': (context) => AuthPage(),
        },
        home: const SplashPage(),
        debugShowCheckedModeBanner: true,
      ),
    );
  }
}
