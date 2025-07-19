import 'package:flutter/material.dart';

class CustomDialog {
  static void show({
    required BuildContext context,
    required String message,
    required String buttonText,
    String? title,
    bool isSuccess = true,
    VoidCallback? onConfirmed,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // 圆角边框
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Text(
                title ?? (isSuccess ? 'Success' : 'Error'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 消息内容
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 按钮
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭弹窗
                  if (onConfirmed != null) {
                    onConfirmed(); // 可选回调
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40), // 字体颜色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // 圆角按钮
                  ),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
