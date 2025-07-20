import 'package:easy_chat/config/app_configs.dart';
import 'package:easy_chat/pages/profile/edit/edit_profile_page.dart';
import 'package:easy_chat/services/websocket_manager.dart';
import 'package:easy_chat/store/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/peer_user.dart';
import '../../provider/post_provider.dart';
import '../../provider/user_provider.dart';
import '../../utils/page_slide.dart';
import '../commonComponents/circle_icon_button.dart';
import '../commonComponents/confirm_dialog.dart';
import '../user/peer_user_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) {
    // 关闭ws连接
    WebSocketManager().close();
    // 清除token数据
    TokenStorage.clearToken();
    // 清除登录用户信息
    context.read<UserProvider>().clear();
    // 清除帖子加载缓存
    context.read<PostProvider>().clear();
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login', // 目标路由名
          (route) => false, // 移除所有旧路由
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已退出登录')),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmDialog(
          title: '确定要退出登录吗？',
          content: '退出后需要重新登录才能使用完整功能。',
          onConfirm: () => _logout(context),
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    PeerUser user = context.watch<UserProvider>().user;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('我的', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        // elevation: 0,
      ),
      body: ListView(
        children: [
          // 用户卡片加点击跳转
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                  context, slideTransitionTo(PeerUserPage(userId: user.id.toString()))
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      AppConfigs.getResourceUrl(user.avatarUrl ?? ''),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.nickname,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.bio.isEmpty ? '这个人很懒，什么也没有留下~' : user.bio,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  CircleIconButton(
                    icon: Icons.edit,
                    onTap: () {
                      Navigator.push(
                        context,
                        slideTransitionTo(EditProfilePage(user: user)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 统计项
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('帖子', 15),
                _buildStatItem('获赞', 78),
                _buildStatItem('收藏', 12),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 功能列表
          _buildMenuItem(
            icon: Icons.article_outlined,
            text: '我的帖子',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.bookmark_outline,
            text: '我的收藏',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            text: '设置',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.logout,
            text: '退出登录',
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            onTap: () {
              _showLogoutConfirm(context);
            },
          ),
        ],
      ),
    );

  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleIconButton(
        icon: icon,
        iconColor: iconColor ?? Colors.black87,
        onTap: () {}, // 这里单独点击icon不做跳转，点击整行才跳转
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
