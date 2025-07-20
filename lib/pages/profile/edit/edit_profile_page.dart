import 'dart:io';

import 'package:easy_chat/config/app_configs.dart';
import 'package:easy_chat/provider/user_provider.dart';
import 'package:easy_chat/utils/tip_util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/peer_user.dart';
import '../../../services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  final PeerUser user;

  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}


class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;
  late Gender _selectedGender;

  File? _pickedAvatarFile;
  File? _pickedBackgroundFile;

  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.user.nickname);
    _bioController = TextEditingController(text: widget.user.bio);
    _selectedGender = widget.user.gender ?? Gender.OTHER;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isAvatar) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      if (isAvatar) {
        _pickedAvatarFile = File(picked.path);
      } else {
        _pickedBackgroundFile = File(picked.path);
      }
    });
  }

  Future<void> _save() async {
    final nickname = _nicknameController.text.trim();
    final bio = _bioController.text.trim();

    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('昵称不能为空')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      PeerUser? user = await UserService.updateUser(
        nickname: nickname,
        gender: _selectedGender.name,
        bio: bio,
        avatar: _pickedAvatarFile,
        background: _pickedBackgroundFile,
      );

      if (user == null) {
        if (mounted) {
          TipUtils.showTip(context: context, message: '保存失败！');
        }
        return;
      }
      if (mounted) {
        TipUtils.showTip(context: context, message: '修改成功！');
        context.read<UserProvider>().updateUser(user);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _genderOption({
    required Gender value,
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
              value.name[0] + value.name.substring(1).toLowerCase(), // Format to "Male"
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
    final avatarWidget = _pickedAvatarFile != null
        ? CircleAvatar(radius: 50, backgroundImage: FileImage(_pickedAvatarFile!))
        : (widget.user.avatarUrl != null
        ? CircleAvatar(radius: 50, backgroundImage: NetworkImage(AppConfigs.getResourceUrl(widget.user.avatarUrl!)))
        : const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)));

    final backgroundWidget = _pickedBackgroundFile != null
        ? Image.file(_pickedBackgroundFile!, fit: BoxFit.cover)
        : (widget.user.backgroundUrl != null
        ? Image.network(AppConfigs.getResourceUrl(widget.user.backgroundUrl!), fit: BoxFit.cover)
        : Container(color: Colors.grey.shade300));

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _isSaving ? null : _save,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSaving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                    )
                        : const Icon(Icons.save, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 背景图选择
            _buildSectionTitle('主页背景'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _pickImage(false),
              child: _buildImagePicker(backgroundWidget),
            ),
            const SizedBox(height: 24),

            // 头像选择
            _buildSectionTitle('头像'),
            const SizedBox(height: 8),
            Center(
              child: Stack(
                children: [
                  avatarWidget,
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => _pickImage(true),
                      child: _buildEditButton(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 昵称 & 性别 & 签名卡片
            _buildInfoCard(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // 标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  // 图片选择器布局
  Widget _buildImagePicker(Widget backgroundWidget) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          backgroundWidget,
          Container(
            color: Colors.black.withOpacity(0.25),
            child: const Center(
              child: Icon(Icons.camera_alt, color: Colors.white, size: 40),
            ),
          ),
        ],
      ),
    );
  }

  // 编辑按钮
  Widget _buildEditButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      padding: const EdgeInsets.all(6),
      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
    );
  }

  // 个人信息输入卡片
  Widget _buildInfoCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 昵称
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                  labelText: '昵称',
                  hintText: '请输入昵称...',
                  labelStyle: TextStyle(
                      color: Colors.black
                  ),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green))
              ),
            ),
            const SizedBox(height: 20),

            // // 性别
            // Text(
            //   '性别',
            //   style: Theme.of(context).textTheme.titleMedium,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _genderOption(value: Gender.MALE, icon: Icons.male),
                _genderOption(value: Gender.FEMALE, icon: Icons.female),
                _genderOption(value: Gender.OTHER, icon: Icons.transgender),
              ],
            ),
            const SizedBox(height: 20),

            // 签名
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: '签名',
                hintText: '说点什么吧...',
                labelStyle: TextStyle(
                  color: Colors.black
                ),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green))
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
