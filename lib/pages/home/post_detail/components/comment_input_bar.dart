import 'package:easy_chat/models/post.dart';
import 'package:flutter/material.dart';

import '../../../../models/post_comments.dart';

class CommentInputBar extends StatefulWidget {
  final Post post;

  final VoidCallback onLike;

  final VoidCallback onFavorite;

  final void Function(Comment? replyingComment) onReplyPressed;

  const CommentInputBar({
    super.key,
    required this.post, required this.onLike, required this.onFavorite, required this.onReplyPressed,
  });

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  @override
  Widget build(BuildContext context) {
    const countTextStyle = TextStyle(fontSize: 14, color: Colors.grey);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.3)),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 6, right: 16),
          child: Row(
            children: [
              // 伪输入框
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    widget.onReplyPressed(null);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      '写评论...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // 点赞 + 数量
              GestureDetector(
                onTap: widget.onLike,
                child: Row(
                  children: [
                    Icon(
                      widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 30,
                      color: widget.post.isLiked ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(widget.post.likeCount.toString(), style: countTextStyle),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // 收藏 + 数量
              GestureDetector(
                onTap: widget.onFavorite,
                child: Row(
                  children: [
                    Icon(
                      widget.post.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      size: 30,
                      color: widget.post.isFavorite ? Colors.amber : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(widget.post.favoriteCount.toString(), style: countTextStyle),
                  ],
                ),
              ),
            ],

          ),
        ),
      ),
    );
  }
}
