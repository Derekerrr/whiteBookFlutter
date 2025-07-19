import 'package:easy_chat/pages/register/step_username.dart';
import 'package:flutter/material.dart';
import '../../utils/page_slide.dart';
import '../../widgets/login_form.dart' as login;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  void toggleMode() {
    Navigator.push(
      context, slideTransitionTo(const StepUsernamePage())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: login.LoginForm(onToggle: toggleMode)
            ),
          ],
        ),
      ),
    );
  }
}
