import 'dart:io';
import 'package:easy_chat/provider/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/post_service.dart';
import '../../utils/custom_dialog.dart';
import '../main_page.dart';

class PublishPostPage extends StatefulWidget {
  const PublishPostPage({super.key});

  @override
  State<PublishPostPage> createState() => _PublishPostPageState();
}

class _PublishPostPageState extends State<PublishPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isPublishing = false;

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能选择9张图片')),
      );
      return;
    }

    final List<XFile> picked = await _picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(
          picked.take(9 - _selectedImages.length).map((x) => File(x.path)),
        );
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _handlePublish() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (_selectedImages.isEmpty) {
      CustomDialog.show(context: context, message: '请选择图片', buttonText: 'OK', isSuccess: false);
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final result = await PostService.publishPost(
        title: title,
        content: content.isEmpty ? null : content,
        images: _selectedImages,
      );

      if (mounted) {
        if (result?['code'].toString() == '200') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('发布成功')),
          );
          // 清除所有帖子重新加载
          context.read<PostProvider>().clear();
          // 跳转到主页
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          CustomDialog.show(context: context, message: result?['message'], buttonText: 'OK', isSuccess: false);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发布失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('发布', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _isPublishing ? null : _handlePublish,
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
                    child: _isPublishing
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                    )
                        : const Icon(Icons.send, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '标题',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            SizedBox(
              child: TextField(
                controller: _contentController,
                minLines: 4, // 👈 这里设置最小显示6行
                maxLines: null, // 不限制最大行数
                style: const TextStyle(fontSize: 16),
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: '分享你的想法...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._selectedImages.asMap().entries.map(
                      (entry) {
                    final index = entry.key;
                    final file = entry.value;

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (_selectedImages.length < 9)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: const Icon(Icons.add, size: 32, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
