import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 引入用于设置输入格式的包
import 'package:easy_chat/utils/input_styles.dart';
import '../../utils/custom_elevated_button.dart';
import '../../utils/page_slide.dart';
import 'common/register_appbar.dart';
import 'step_avatar.dart';

class PasswordStepPage extends StatefulWidget {
  final String username;

  const PasswordStepPage({super.key, required this.username});

  @override
  State<PasswordStepPage> createState() => _PasswordStepPageState();
}

class _PasswordStepPageState extends State<PasswordStepPage> {
  final _formKey = GlobalKey<FormState>();
  String _password = '';
  String _confirmPassword = '';
  final bool _isLoading = false;

  // 提取公共密码输入框的逻辑，并添加最大长度限制
  Widget _passwordTextField(String hintText, bool isConfirmPassword) {
    return TextFormField(
      decoration: roundedInputDecoration(hintText),
      obscureText: true,
      onSaved: (val) {
        isConfirmPassword ? _confirmPassword = val ?? '' : _password = val ?? '';
      },
      validator: (val) => val == null || val.length < 6
          ? 'Password must be at least 6 characters long'
          : null,
      inputFormatters: [
        LengthLimitingTextInputFormatter(20), // 限制字符输入为 20 个
      ],
    );
  }

  // 下一步按钮逻辑
  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_password != _confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      // 如果验证成功，进入下一步页面
      Navigator.push(
        context, slideTransitionTo(AvatarStepPage(
        username: widget.username,
        password: _password,
        gender: 'OTHER', nickname: '', // 可以通过传递给 AvatarStepPage 参数
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: registerAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Please set up your password",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 18),
              _passwordTextField("Enter password", false),
              const SizedBox(height: 16),
              _passwordTextField("Confirm password", true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                    onPressed: _nextStep,
                    isLoading: _isLoading,
                    buttonText: 'Next'
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
