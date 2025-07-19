import 'package:easy_chat/models/type/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/post_provider.dart';
import '../../services/post_service.dart';
import 'components/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;
  int _page = 1; // 当前页码
  int _totalPages = 1; // 总页数
  String? _lastId;

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 到底提示
  bool _isLoadOver = false;

  @override
  void initState() {
    super.initState();
    _onScroll();
    _loadPosts();
  }

  /// 加载帖子数据
  Future<void> _loadPosts() async {
    if (_loading || _page > _totalPages) return;

    setState(() {
      _loading = true;
    });

    try {
      final postPage = await PostService.getPosts(page: _page, id: _lastId);

      // 用 Provider 保存，不要自己 setState 保存
      if (mounted) {
        if (_page == 1) {
          context.read<PostProvider>().setPosts(postPage.content);
        } else {
          context.read<PostProvider>().addPosts(postPage.content);
        }
      }

      setState(() {
        _page++;
        _totalPages = postPage.totalPages;
        _loading = false;
        _isLoadOver = _page > _totalPages;

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

  /// 滚动监听：滑到底就自动加载更多
  void _onScroll() {
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll && !_loading) {
        _loadPosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// build
  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>().posts;

    return Scaffold(
      appBar: AppBar(
        title: const Text("首页", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
      ),
      body: _loading && posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          _page = 1;
          _totalPages = 1;
          _lastId = null;
          context.read<PostProvider>().clear();
          await _loadPosts();
        },
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio: 0.6,
            ),
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
              if (index < posts.length) {
                return PostCard(post: posts[index], cardParentPage: CardParentPage.homePae);
              } else {
                return SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _isLoadOver ? "—— 没有啦 ——" : "",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
