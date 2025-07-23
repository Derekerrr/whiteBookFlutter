import 'package:easy_chat/config/app_configs.dart';
import 'package:flutter/material.dart';
import '../../../../models/post.dart';
import '../../../../utils/page_slide.dart';
import '../../../user/peer_user_page.dart';

class PostAppBar extends StatefulWidget {
  final Post post;

  const PostAppBar({super.key, required this.post});

  @override
  State<PostAppBar> createState() => _PostAppBarState();
}

class _PostAppBarState extends State<PostAppBar> {

  void _handleTapUserNameOrAvatar() {
    Navigator.push(
        context, slideTransitionTo(PeerUserPage(userId: widget.post.userId))
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          // 👇 这里自定义返回逻辑
          Navigator.pop(context, widget.post.isLiked);
          // 或者执行你自己的逻辑
        },
      ),
      pinned: true,
      expandedHeight: 0,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 12),
        title: Row(
          children: [
            // Avatar 点击事件
            GestureDetector(
              onTap: () {
                _handleTapUserNameOrAvatar();
              },
              child: CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(AppConfigs.getResourceUrl(widget.post.userAvatar)),
              ),
            ),
            const SizedBox(width: 8),

            GestureDetector(
              onTap: () {
                _handleTapUserNameOrAvatar();
              },
              child: Text(
                widget.post.userNickname,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            )

          ],
        )
      ),
    );
  }
}
