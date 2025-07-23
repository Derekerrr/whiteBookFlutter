import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/dto/post_comment_request.dart';
import '../../../models/post.dart';
import '../../../models/post_comments.dart';
import '../../../provider/post_provider.dart';
import '../../../services/comment_service.dart';
import '../../../services/post_like_service.dart';
import '../../../utils/tip_util.dart';
import 'components/comment_input_bar.dart';
import 'components/comment_item.dart';
import 'components/emoji_comment_input.dart';
import 'components/post_app_bar.dart';
import 'components/post_image_slider.dart';
import 'components/post_title.dart';
import 'components/post_content.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  int currentCommentPage = 0;
  int currentImageIndex = 0;
  late Post post;
  bool _isCommentPosting = false;  // 加载状态变量，表示是否正在发送评论
  late final List<Comment> _comments = [];
  bool _loadOver = false;
  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    post = widget.post;
    // 加载评论数据
    _loadComments();
    _onScroll();
  }

  // 加载评论数据
  void _loadComments() async {
    setState(() {
      _isCommentPosting = true;  // 开始加载
    });

    try {
      // 调用 CommentService 获取评论
      final commentPage = await CommentService.getComments(
        postId: post.id.toString(),
        pageNum: currentCommentPage + 1,  // 根据页码请求
        pageSize: 5,  // 每页 10 条评论
      );

      // 更新评论列表
      setState(() {
        currentCommentPage ++;
        _comments.addAll(commentPage.content);  // 将获取到的评论保存到 _comments
        _loadOver = currentCommentPage >= commentPage.totalPages;
      });
    } catch (e) {
      print('Error loading comments: $e');
      // 可以显示提示消息给用户
    } finally {
      setState(() {
        _isCommentPosting = false;  // 结束加载
      });
    }
  }

  Comment? _replyingComment;
  final TextEditingController _inputController = TextEditingController();

  // 点击喜欢按钮
  Future<void> _handleLike() async {
    late bool res;
    if (!post.isLiked) {
      res = await PostLikeService.likePost(post.id);
    } else {
      res = await PostLikeService.unlikePost(post.id);
    }
    if (res) {
      setState(() {
        post.isLiked = !post.isLiked;
        post.likeCount += post.isLiked ? 1 : -1;
      });
      if (mounted) {
        context.read<PostProvider>().updatePost(post);
        TipUtils.showTip(
          context: context,
          message: post.isLiked ? "点赞成功" : '已取消',
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

  // 点击收藏按钮
  void _handleFavorite() {
    int count = post.favoriteCount;
    count += post.isFavorite ? -1 : 1;
    setState(() {
      post = post.copyWith(isFavorite: !post.isFavorite, favoriteCount: count);
    });
  }

  // 发送评论请求并处理
  void _sendComment(String text) async {
    final pureText = text.trim();
    if (pureText.isEmpty) return;

    // 创建 PostCommentRequest 请求体
    final postCommentRequest = _createPostCommentRequest(pureText);

    // 设置加载状态为 true
    setState(() {
      _isCommentPosting = true;
    });

    try {
      // 调用 CommentService 发布评论请求
      final newComment = await CommentService.publishComment(postCommentRequest);

      // 更新本地评论列表，插入新评论
      if (_replyingComment == null) {
        // 一级评论
        _comments.add(newComment);
      } else {
        // 二级回复评论
        final targetParentId = _getTargetParentId(_replyingComment!);
        _addReply(_comments, targetParentId, newComment);
      }

      // 更新 UI
      setState(() {
        _isCommentPosting = false; // 结束加载提示
        _replyingComment = null;
        _inputController.clear();
        post.commentCount = post.commentCount + 1;
      });

      if (mounted) {
        context.read<PostProvider>().updatePost(post);
        TipUtils.showTip(
          context: context,
          message: "评论成功",
          duration: const Duration(seconds: 2),
        );
      }

    } catch (e) {
      // 处理评论发布失败
      setState(() {
        _isCommentPosting = false; // 结束加载提示
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send comment: $e'),
      ));
    }
  }

  // 创建 PostCommentRequest 请求体
  PostCommentRequest _createPostCommentRequest(String content) {
    return PostCommentRequest(
      postId: widget.post.id,
      parentId: _replyingComment == null ? null : _replyingComment!.parentId ?? _replyingComment!.id,
      repliedCommentId: _replyingComment?.id,
      repliedUserId: _replyingComment?.userId,
      content: content,
    );
  }

  // 获取目标父评论 ID（处理一级评论和回复评论）
  String _getTargetParentId(Comment replyingComment) {
    return replyingComment.parentId ?? replyingComment.id;
  }

  // 将回复添加到评论列表中的指定父评论下
  void _addReply(List<Comment> comments, String parentId, Comment newComment) {
    for (var comment in comments) {
      if (comment.id == parentId) {
        comment.replies.add(newComment);
        comment.childCount = comment.childCount + 1;
        return;
      }
    }
  }

  // 显示评论输入框
  void _showRealInput(Comment? replyingComment) async {
    _replyingComment = replyingComment;

    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EmojiCommentInput(
          onSend: (value) {
            Navigator.of(context).pop(value);
          },
          repliedUserNickname: _replyingComment?.userNickname
      ),
    );

    if (text != null && text.trim().isNotEmpty) {
      _sendComment(text.trim());
    }
  }

  // 加载更多子评论
  Future<void> _loadMoreChildComments(Comment comment) async {
    setState(() {
      _isCommentPosting = true;  // 开始加载
    });

    try {
      // 调用 CommentService 获取评论
      final commentPage = await CommentService.getComments(
        postId: post.id.toString(),
        replyPageNum: comment.childPage + 1,
        parentId: comment.id
      );

      // 更新评论列表
      setState(() {
        comment.replies.addAll(commentPage.content);
        comment.childPage ++;
        comment.hasMoreChild = !commentPage.isLast;
      });

    } catch (e) {
      print('Error loading comments: $e');
      // 可以显示提示消息给用户
    } finally {
      setState(() {
        _isCommentPosting = false;  // 结束加载
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 记得清理控制器
    super.dispose();
  }

  // 检查是否滑动到页面底部
  void _onScroll() {
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll == maxScroll && !_isCommentPosting && !_loadOver) {
         _loadComments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          PostAppBar(post: post),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                PostImageSlider(
                  images: post.images,
                  onPageChanged: (index) {
                    setState(() => currentImageIndex = index);
                  },
                  currentPage: currentImageIndex,
                ),
                if (post.title != null && post.title!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: PostTitle(title: post.title),
                  ),
                if (post.content != null && post.content!.isNotEmpty)
                  PostContent(post: post),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: const Divider(),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('共${widget.post.commentCount}条评论', style: Theme.of(context).textTheme.titleSmall),
                ),
                ..._comments.map(
                      (comment) => CommentItem(
                    comment: comment,
                    onReplyPressed: _showRealInput,
                    isFirstLevel: true,
                    onLoadMorePressed: _loadMoreChildComments,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _loadOver ? '-- 到底了 --': '',
                      style: TextStyle(
                        color: Colors.black45
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80), // 给输入栏留空间
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommentInputBar(
        onLike: _handleLike,
        onFavorite: _handleFavorite,
        post: this.post,
        onReplyPressed: _showRealInput,
      ),
      // 加载时显示一个 CircularProgressIndicator
      floatingActionButton: _isCommentPosting
          ? FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: CircularProgressIndicator(),
      )
          : null,
    );
  }
}

