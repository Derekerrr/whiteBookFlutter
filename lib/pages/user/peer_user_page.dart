import 'package:easy_chat/config/app_configs.dart';
import 'package:easy_chat/models/type/app_enums.dart';
import 'package:easy_chat/pages/conversation/chat/chat_page.dart';
import 'package:easy_chat/provider/conversation_provider.dart';
import 'package:easy_chat/provider/user_provider.dart';
import 'package:easy_chat/services/post_service.dart';
import 'package:easy_chat/services/user_service.dart';
import 'package:easy_chat/utils/page_slide.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/chat_database.dart';
import '../../models/peer_user.dart';
import '../../models/post.dart';
import '../home/components/post_card.dart';

class PeerUserPage extends StatefulWidget {
  final String userId;

  const PeerUserPage({
    super.key,
    required this.userId,
  });

  @override
  State<PeerUserPage> createState() => _PeerUserPageState();
}

class _PeerUserPageState extends State<PeerUserPage> {
  final List<Post> _posts = [];
  bool isUserLoading = true; // Add a separate loading flag for user data
  PeerUser _user = PeerUser(id: 1, nickname: '加载中...');

  // 分页相关
  bool _loading = false;
  int _page = 1; // 当前页码
  int _totalPages = 1; // 总页数
  String? _lastId;
  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 显示提示框的状态
  bool _isLoadOver = false;

  @override
  void initState() {
    _loadUser();
    _loadPosts();
    _onScroll();

    super.initState();
  }

  // 检查是否滑动到页面底部
  void _onScroll() {
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll == maxScroll && !_loading) {
        _loadPosts();
      }
    });
  }

  // 加载帖子数据
  Future<void> _loadPosts() async {
    if (_loading || _page > _totalPages) return; // 防止重复加载和超出页码
    setState(() {
      _loading = true; // 开始加载时显示加载指示器
    });

    try {
      final postPage = await PostService.getPosts(page: _page, id: _lastId, ownerId: widget.userId);
      // 使用 setState() 直接更新 UI
      setState(() {
        _posts.addAll(postPage.content); // 将新加载的帖子添加到现有列表
        _page++; // 增加页码
        _totalPages = postPage.totalPages; // 更新总页数
        _loading = false; // 停止加载指示器

        setState(() {
          _isLoadOver = _page > _totalPages; // 隐藏提示框
        });

        if (postPage.content.isNotEmpty && _lastId == null) {
          _lastId = postPage.content[0].id.toString();
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print('Error loading posts: $e');
    }
  }


  Future<void> _loadUser() async {
    try {
      final fetchUser = await UserService.getUserById(widget.userId.toString());
      if (fetchUser != null) {
        setState(() {
          _user = fetchUser;
          isUserLoading = false; // User data loaded
        });
      }
    } catch (e) {
      setState(() {
        isUserLoading = false; // Hide the loading indicator if there is an error
      });
      if (mounted) {
        // Handle error (maybe show an error message)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading user')));
      }
    }
  }

  Future<void> _handlePrivateMessage() async {
    final PeerUser loginUser = context.read<UserProvider>().user;

    // 检查是否已有与目标用户的对话
    final existingConversation = context.read<ConversationProvider>().getConversationWithPeer(loginUser.id, _user.id);

    if (existingConversation != null) {
      print('conversation with ${_user.nickname} is existed.');
      // 如果已有对话，直接进入聊天页面
      if (mounted) {
        Navigator.push(
            context,
            slideTransitionTo(ChatPage(conversation: existingConversation, peerUser: _user))
        );
      }
    } else {
      print('conversation with ${_user.nickname} is not existed, now create one');
      // 如果没有对话，创建一个新的会话
      ChatConversation? conversationJustCreated = await context.read<ConversationProvider>().createNewConversation(loginUser, _user);

      // 进入聊天页面，传递新创建的会话ID
      if (mounted) {
        Navigator.push(
          context,
          slideTransitionTo(ChatPage(conversation: conversationJustCreated!, peerUser: _user,)),
        );
      }
    }
  }

  Widget _buildStatusDot(UserStatus? status) {
    Color color;
    String text;
    switch (status) {
      case UserStatus.ONLINE:
        color = Colors.greenAccent;
        text = "在线";
        break;
      case UserStatus.OFFLINE:
      default:
        color = Colors.grey;
        text = "离线";
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildGenderIcon(Gender? gender) {
    IconData iconData;
    Color color;
    switch (gender) {
      case Gender.MALE:
        iconData = Icons.male;
        color = Colors.blueAccent;
        break;
      case Gender.FEMALE:
        iconData = Icons.female;
        color = Colors.pinkAccent;
        break;
      default:
        iconData = Icons.person_outline;
        color = Colors.grey.shade400;
    }
    return Icon(iconData, color: color, size: 18);
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = _user.isMe;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isUserLoading ? "加载中..." : _user.nickname,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: isUserLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader until user data is fetched
          : SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        AppConfigs.getResourceUrl(_user.backgroundUrl ?? ''),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _user.avatarUrl != null
                              ? NetworkImage(AppConfigs.getResourceUrl(_user.avatarUrl!))
                              : null,
                          backgroundColor: Colors.grey.shade400,
                          child: _user.avatarUrl == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 24),
                          _buildStatusDot(_user.status),
                          _buildGenderIcon(_user.gender),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _user.bio.isEmpty ? '这个人很懒，什么也没有留下~' : _user.bio,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem("帖子", _user.postCount),
                      _buildStatItem("关注", _user.followingCount),
                      _buildStatItem("粉丝", _user.followersCount),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (!isMe)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(_user.isFollowing ? Icons.check : Icons.person_add),
                            label: Text(_user.isFollowing ? "已关注" : "关注"),
                            onPressed: () {
                              // 这里写关注/取消逻辑
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: _user.isFollowing ? Colors.red : Colors.green, // 文本和图标颜色
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.chat),
                            label: const Text("私信"),
                            onPressed: _handlePrivateMessage,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: _user.isFollowing ? Colors.red : Colors.green, // 文本和图标颜色
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    isMe ? "我的帖子" : "TA的帖子",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_posts.isEmpty)
                    const Center(
                      child: Text(
                        "暂无动态",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    Column(
                      children: _posts
                          .map((post) => PostCard(post: post, cardParentPage: CardParentPage.userPage))
                          .toList(),
                    ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Text(
                        _isLoadOver ? '-- 到底了 --' : '',
                        style: TextStyle(
                            color: Colors.black45
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
