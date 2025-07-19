import 'package:flutter/material.dart';

// 定义一个公共的 ElevatedButton 组件
class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed; // 按钮点击事件
  final bool isLoading; // 是否正在加载
  final String buttonText; // 按钮文本
  final Color? buttonColor; // 按钮背景色
  final EdgeInsetsGeometry? padding; // 按钮的内边距
  final double borderRadius; // 按钮圆角

  // 构造函数
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    required this.buttonText,
    this.buttonColor = Colors.green, // 默认绿色
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor, // 按钮背景色
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding, // 内边距
        elevation: 2, // 阴影
      ),
      child: isLoading
          ? SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Text(
        buttonText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
