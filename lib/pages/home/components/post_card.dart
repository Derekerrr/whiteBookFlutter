import 'package:easy_chat/config/app_configs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/post.dart';
import '../../../models/type/app_enums.dart';
import '../../../provider/post_provider.dart';
import '../../../services/post_like_service.dart';
import '../../../utils/page_slide.dart';
import '../../../utils/tip_util.dart';
import '../post_detail/post_detail_page.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final CardParentPage cardParentPage;

  const PostCard({super.key, required this.post, required this.cardParentPage});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late Post _post;
  late AnimationController _controller;
  double? _imageHeight;  // 用来存储图片的实际高度
  double? _imageWidth;

  @override
  void initState() {
    super.initState();
    _precacheImage();
    _post = widget.post;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
  }

  Future<void> _precacheImage() async {
    final Image image = Image.network(AppConfigs.getResourceUrl(widget.post.images[0].imageUrl));
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) {
        if (mounted) {
          setState(() {
            _imageHeight = info.image.height.toDouble();  // 获取图片的实际高度
            _imageWidth = info.image.width.toDouble();
          });
        }
      }),
    );
  }

  Future<void> _handleLike() async {
    late bool res;
    if (!_post.isLiked) {
      res = await PostLikeService.likePost(widget.post.id);
    } else {
      res = await PostLikeService.unlikePost(widget.post.id);
    }

    if (res) {
      setState(() {
        _post.isLiked = !_post.isLiked;
        _post.likeCount += _post.isLiked ? 1 : -1;
      });
      // 播放动画
      _controller.forward(from: 0.8).then((_) => _controller.reverse());
      if (mounted) {
        context.read<PostProvider>().updatePost(_post);
        TipUtils.showTip(
          context: context,
          message: _post.isLiked ? "点赞成功" : '已取消',
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        bool isTapLiked = await Navigator.push(
            context, slideTransitionTo(PostDetailPage(post: widget.post))
        );
        // 如果父页面是用户主页的话，需手动设置点赞状态
        if (widget.cardParentPage == CardParentPage.userPage) {
          setState(() {
            _post.isLiked = isTapLiked;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
        ),
        child: SingleChildScrollView(  // 使 Column 可滚动
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面图，动态设置图片的 fit
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 限制最大高度
                    double maxHeight = 300;

                    // 检查图片是否为空
                    if (widget.post.images.isEmpty) {
                      return Container();  // 如果没有图片，返回一个空容器
                    }


                    // 获取图片宽高比例
                    double imageAspectRatio = 1.0;
                    if (_imageHeight != null && _imageWidth != null) {
                      imageAspectRatio = widget.post.images.isNotEmpty
                          ? _imageWidth! / _imageHeight!
                          : 1.0;
                    }

                    // 根据图片宽高比例计算图片的高度
                    double imageHeight = constraints.maxWidth / imageAspectRatio;

                    // 判断图片是否超过最大高度，超出则使用 BoxFit.cover，否则保持原始比例
                    BoxFit fit = imageHeight > maxHeight ? BoxFit.cover : BoxFit.fitWidth;

                    return SizedBox(
                      height: imageHeight > maxHeight ? maxHeight : imageHeight, // 最大高度限制
                      width: double.infinity,
                      child: Image.network(
                        AppConfigs.getResourceUrl(widget.post.images[0].imageUrl),
                        fit: fit, // 使用动态 fit
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              // 标题部分，自动根据内容高度变化
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  (widget.post.title?.isNotEmpty ?? false)
                      ? widget.post.title ?? ''
                      : widget.post.content ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 6),
              // 用户信息和点赞部分，固定高度
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    // 用户头像
                    CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(AppConfigs.getResourceUrl(widget.post.userAvatar)),
                    ),
                    const SizedBox(width: 6),
                    // 用户昵称
                    Expanded(
                      child: Text(
                        widget.post.userNickname,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 点赞按钮
                    GestureDetector(
                      onTap: _handleLike,
                      child: ScaleTransition(
                        scale: _controller,
                        child: Row(
                          children: [
                            Icon(
                              _post.isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: _post.isLiked ? Colors.redAccent : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_post.likeCount}',
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
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
