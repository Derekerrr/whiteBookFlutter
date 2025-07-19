import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_chat/services/auth_service.dart';
import '../../utils/custom_dialog.dart';
import '../../utils/input_styles.dart';
import '../../utils/custom_elevated_button.dart';
import 'common/register_appbar.dart';

class AvatarStepPage extends StatefulWidget {
  final String username;
  final String password;
  final String nickname;
  final String gender;

  const AvatarStepPage({
    super.key,
    required this.username,
    required this.password,
    required this.nickname,
    required this.gender,
  });

  @override
  State<AvatarStepPage> createState() => _AvatarStepPageState();
}

class _AvatarStepPageState extends State<AvatarStepPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  File? _avatarFile;
  String? _selectedGender;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.gender;
  }

  Future<void> _pickAvatar() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_avatarFile == null || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all information")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      var result = await AuthService.register(
        widget.username,
        widget.password,
        _controller.text.trim(),
        _selectedGender!,
        _avatarFile!.path,
      );

      if (mounted) {
        if (result == null || result['code'].toString() != '200') {
          CustomDialog.show(
            context: context,
            message: 'register failed！',
            buttonText: 'OK',
            isSuccess: false,
          );
          return;
        }
        CustomDialog.show(
          context: context,
          message: 'register success!！',
          buttonText: 'Go to login',
          isSuccess: true, onConfirmed: () => {
             Navigator.pushReplacementNamed(context, '/login')
        }
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register failed: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _genderOption({
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedGender == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          )
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: isSelected ? Colors.green : Colors.grey),
            const SizedBox(height: 6),
            Text(
              value[0] + value.substring(1).toLowerCase(), // Format to "Male"
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.green : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: registerAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choose your avatar and gender",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                      _avatarFile != null ? FileImage(_avatarFile!) : null,
                      child: _avatarFile == null
                          ? Icon(Icons.add_a_photo,
                          size: 36, color: Colors.grey.shade600)
                          : null,
                    ),
                  ),
                ),
                //
                // /// Gender Selection
                // const Text(
                //   "Select Gender",
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _genderOption(value: "MALE", icon: Icons.male),
                    _genderOption(value: "FEMALE", icon: Icons.female),
                    _genderOption(value: "OTHER", icon: Icons.transgender),
                  ],
                ),
                // Username Input Field
                const SizedBox(height: 12),
                TextFormField(
                    controller: _controller,
                    decoration: roundedInputDecoration('Enter nickname'),
                    maxLength: 20,  // Limit the length of the username
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter username' : null
                ),
                const SizedBox(height: 24),

                /// Submit Button
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                      onPressed: _submit,
                      isLoading: _isSubmitting,
                      buttonText: 'Next'
                  ),
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}
