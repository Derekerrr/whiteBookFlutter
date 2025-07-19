import 'package:flutter/material.dart';
import 'circle_icon_button.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String? content;
  final IconData confirmIcon;
  final IconData cancelIcon;
  final Color confirmIconColor;
  final Color cancelIconColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDialog({
    super.key,
    required this.title,
    this.content,
    this.confirmIcon = Icons.check,
    this.cancelIcon = Icons.close,
    this.confirmIconColor = Colors.green,
    this.cancelIconColor = Colors.grey,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (content != null) ...[
              const SizedBox(height: 16),
              Text(
                content!,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleIconButton(
                  icon: cancelIcon,
                  iconColor: cancelIconColor,
                  backgroundColor: Colors.white,
                  onTap: onCancel,
                ),
                CircleIconButton(
                  icon: confirmIcon,
                  iconColor: confirmIconColor,
                  backgroundColor: Colors.white,
                  onTap: onConfirm,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
