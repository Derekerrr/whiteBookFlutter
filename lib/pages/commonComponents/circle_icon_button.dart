import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  final double padding;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final String? tooltip; // 新增

  const CircleIconButton({
    super.key,
    required this.icon,
    this.iconColor = Colors.black87,
    this.size = 24,
    this.padding = 8,
    this.backgroundColor = Colors.white,
    this.onTap,
    this.tooltip, // 新增
  });

  @override
  Widget build(BuildContext context) {
    Widget button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size,
        ),
      ),
    );

    // 如果提供了 tooltip，则包裹 Tooltip
    if (tooltip != null && tooltip!.isNotEmpty) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
