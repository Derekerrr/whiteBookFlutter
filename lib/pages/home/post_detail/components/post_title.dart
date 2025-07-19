import 'package:flutter/material.dart';

class PostTitle extends StatelessWidget {
  final String? title;

  const PostTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: title == null ? 16 : 0),
      child: Text(
        title ?? '',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
