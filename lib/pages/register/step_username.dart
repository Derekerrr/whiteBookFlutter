import 'package:easy_chat/pages/register/step_password.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/custom_dialog.dart';
import '../../utils/custom_elevated_button.dart';
import '../../utils/input_styles.dart';
import 'package:easy_chat/pages/register/common/register_appbar.dart';

import '../../utils/page_slide.dart';

class StepUsernamePage extends StatefulWidget {
  const StepUsernamePage({super.key});

  @override
  State<StepUsernamePage> createState() => _StepUsernamePageState();
}

class _StepUsernamePageState extends State<StepUsernamePage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _checking = false;

  // Check if username already exists
  Future<void> _checkUsername() async {
    if (!_formKey.currentState!.validate()) return;

    String username = _controller.text.trim();

    if (username.isEmpty) return;

    setState(() => _checking = true);

    bool taken = await AuthService.checkUsernameExists(username);

    setState(() => _checking = false);

    if (mounted) {
      if (taken) {
        CustomDialog.show(
          context: context,
          message: 'Username already taken',
          buttonText: 'OK',
          isSuccess: false,
        );
      } else {
        // Username available -> navigate to next page
        Navigator.push(
            context, slideTransitionTo(PasswordStepPage(username: username))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: registerAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choose your login username which is unmodifiable",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 18),

                // Username Input Field
                TextFormField(
                    controller: _controller,
                    decoration: roundedInputDecoration('Enter username'),
                    maxLength: 20,  // Limit the length of the username
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter username' : null
                ),

                const SizedBox(height: 24),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    onPressed: _checkUsername,
                    isLoading: _checking,
                    buttonText: 'Next'
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
