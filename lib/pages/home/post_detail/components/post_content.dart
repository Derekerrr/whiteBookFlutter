import 'package:easy_chat/models/post.dart';
import 'package:easy_chat/utils/time_utils.dart';
import 'package:flutter/material.dart';

class PostContent extends StatefulWidget {
  final Post post;

  const PostContent({super.key, required this.post});

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.post.content ?? '',
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Text(
                TimeUtils.formatSmartTime(widget.post.postTime),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.values[3]
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
