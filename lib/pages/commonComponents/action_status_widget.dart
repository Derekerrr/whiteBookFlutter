import 'package:flutter/material.dart';

class ActionTipWidget extends StatefulWidget {
  final String message;       // 提示文本
  final Duration duration;    // 提示显示时间
  final Color backgroundColor; // 提示框背景色
  final Color textColor;        // 提示文本颜色
  final double borderRadius;  // 提示框圆角

  // 构造函数
  const ActionTipWidget({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 2),
    this.backgroundColor = Colors.black45,
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
  });

  @override
  State<ActionTipWidget> createState() => _ActionTipWidgetState();
}

class _ActionTipWidgetState extends State<ActionTipWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;  // 动画控制器
  late Animation<double> _opacity;       // 透明度动画

  @override
  void initState() {
    super.initState();

    // 创建动画控制器和透明度动画
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);

    // 启动提示显示动画
    _showTip();
  }

  // 显示提示
  void _showTip() {
    _controller.forward();

    // 在指定时间后，自动消失
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // 清理动画控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Text(
              widget.message,
              style: TextStyle(
                color: widget.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
