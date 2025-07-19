import 'package:easy_chat/config/app_configs.dart';
import 'package:easy_chat/pages/user/peer_user_page.dart';
import 'package:easy_chat/services/comment_like_service.dart';
import 'package:easy_chat/utils/time_utils.dart';
import 'package:flutter/material.dart';
import '../../../../models/post_comments.dart';
import '../../../../utils/page_slide.dart';
import '../../../../utils/tip_util.dart';
import 'nickname_with_reply.dart';

class CommentItem extends StatefulWidget {
  final Comment comment;
  final bool isFirstLevel;
  final void Function(Comment replyingComment) onReplyPressed;
  final void Function(Comment comment) onLoadMorePressed;  // 添加加载更多的回调

  const CommentItem({
    super.key,
    required this.comment,
    required this.onReplyPressed,
    required this.isFirstLevel,
    required this.onLoadMorePressed,  // 初始化加载更多的回调
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Comment _comment;
  late double _paddingRight;

  @override
  void initState() {
    super.initState();
    _comment = widget.comment;
    _paddingRight = widget.isFirstLevel ? 12 : 0;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
  }

  Future<void> _handleLike() async {
    late bool res;
    if (!_comment.isLiked) {
      res = await CommentLikeService.likeComment(_comment.id);
    } else {
      res = await CommentLikeService.unlikeComment(_comment.id);
    }

    if (res) {
      setState(() {
        _comment.isLiked = !_comment.isLiked;
        _comment.likeCount += _comment.isLiked ? 1 : -1;
      });
      // 播放动画
      _controller.forward(from: 0.8).then((_) => _controller.reverse());
      if (mounted) {
        TipUtils.showTip(
          context: context,
          message: _comment.isLiked ? "点赞成功" : '已取消',
          duration: const Duration(seconds: 2),
        );

      }
    } else {
      if (mounted) {
        TipUtils.showTip(
          context: context,
          message: "失败",
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  void _handleTapUserNameOrAvatar(String userId) {
    Navigator.push(
        context, slideTransitionTo(PeerUserPage(userId: userId))
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onReplyPressed(widget.comment);
      },
      child: Padding(
        padding: EdgeInsets.only(left: 12, right: _paddingRight, top: 4, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像 + 昵称 + 回复按钮
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _handleTapUserNameOrAvatar(widget.comment.userId);
                  },
                  child: CircleAvatar(
                    radius: widget.comment.parentId == null ? 18 : 12,
                    backgroundImage: NetworkImage(
                      AppConfigs.getResourceUrl(widget.comment.userAvatar),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NicknameWithReply(
                    userNickname: widget.comment.userNickname,
                    repliedUserNickname: widget.comment.repliedUserNickname,
                    onUserTap: () {
                      print('点击了主昵称：${widget.comment.userNickname}');
                      _handleTapUserNameOrAvatar(widget.comment.userId);
                    },
                    onRepliedUserTap: widget.comment.repliedUserNickname != null
                        ? () {
                      print('点击了被回复昵称：${widget.comment.repliedUserNickname}');
                      _handleTapUserNameOrAvatar(widget.comment.repliedUserId!);
                    }
                        : null,
                  ),
                ),
                GestureDetector(
                  onTap: _handleLike,
                  child: ScaleTransition(
                    scale: _controller,
                    child: Row(
                      children: [
                        Icon(
                          _comment.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 22,
                          color: widget.comment.isLiked ? Colors.redAccent : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_comment.likeCount}',
                          style: const TextStyle(fontSize: 18, color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            Padding(
              padding: EdgeInsets.only(left: widget.comment.parentId == null ? 45 : 35, right: 15),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.comment.content,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(text: '  '), // 空格分隔
                    TextSpan(
                      text: TimeUtils.formatSmartTime(widget.comment.createTime), // 这里假设有 time
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),
            // 子评论列表
            ...widget.comment.replies.map(
                  (reply) => Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: CommentItem(
                  comment: reply,
                  onReplyPressed: widget.onReplyPressed,
                  isFirstLevel: false,
                  onLoadMorePressed: widget.onLoadMorePressed,  // 传递回调
                ),
              ),
            ),

            // 如果有更多子评论，显示“加载更多”
            if (widget.comment.hasMoreChild)
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 0),
                child: TextButton(
                  onPressed: () {
                    widget.onLoadMorePressed(widget.comment);  // 调用加载更多评论的回调
                  },
                  child: Text(
                    '展开${_comment.childCount - _comment.replies.length}条回复...',
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.normal
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
