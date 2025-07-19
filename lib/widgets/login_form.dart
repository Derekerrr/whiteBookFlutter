import 'package:easy_chat/models/peer_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../services/auth_service.dart';
import '../services/websocket_manager.dart';
import '../store/login_user_storage.dart';
import '../store/token_storage.dart';
import '../utils/custom_dialog.dart';
import '../utils/custom_elevated_button.dart';
import '../utils/input_styles.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onToggle;

  const LoginForm({super.key, required this.onToggle});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _loginFormKey = GlobalKey<FormState>();
  String username = '';
  String password = '';

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await AuthService.login(
      _usernameController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      if (result == null || result['code'].toString() != '200') {
        CustomDialog.show(
          context: context,
          buttonText: 'OK',
          message: result != null ? result['message'] : 'login failed: Network Error',
          isSuccess: false,
        );
        return;
      }

      // ✅ 持久化保存 token和用户信息
      TokenStorage.saveToken(result['data']['token']);
      LoginUserStorage.saveUser(PeerUser.fromJson(result['data']['user']));

      // 加载全局用户信息
      context.read<UserProvider>().user = PeerUser.fromJson(result['data']['user']);

      // 初始化并连接 WebSocket
      // WebSocketManager().init();
      WebSocketManager().connect();

      CustomDialog.show(
          context: context,
          message: 'register success!',
          buttonText: 'OK',
          isSuccess: true, onConfirmed: () => {
            Navigator.of(context).pushNamedAndRemoveUntil(
            '/main',     // 目标路由名
              (route) => false, // 移除所有旧路由
            )
      }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _loginFormKey,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 100, // 你可以按需设置大小
                    height: 100,
                  ),
                  const Text(
                    "White Book",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _usernameController,
                    decoration: roundedInputDecoration('Username'),
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter username' : null,
                  ),

                  SizedBox(height: 10),

                  TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: roundedInputDecoration('Password'),
                      validator: (val) =>
                      val == null || val.isEmpty ? 'Please enter Password' : null,
                  ),

                  const SizedBox(height: 30),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 登录按钮
                      CustomElevatedButton(
                        onPressed: _submit,
                        isLoading: _isLoading,
                        buttonText: 'Login',
                      ),

                      SizedBox(height: 12), // 按钮间距

                      CustomElevatedButton(
                        onPressed: widget.onToggle,
                        buttonText: 'Create new account',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
