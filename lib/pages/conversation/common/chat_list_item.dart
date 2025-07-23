import 'package:easy_chat/config/app_configs.dart';
import 'package:easy_chat/models/peer_user.dart';
import 'package:easy_chat/pages/conversation/chat/chat_page.dart';
import 'package:easy_chat/utils/page_slide.dart';
import 'package:easy_chat/utils/time_utils.dart';
import 'package:easy_chat/utils/tip_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../database/chat_database.dart';
import '../../../provider/conversation_provider.dart';
import '../../commonComponents/confirm_dialog.dart';

class ChatListItem extends StatelessWidget {
  final ChatConversation conversation;

  const ChatListItem({super.key, required this.conversation});

  void deleteConversation(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    context.read<ConversationProvider>().deleteConversation(conversation.id);
    TipUtils.showTip(
      context: context,
      message: "删除成功",
      duration: const Duration(seconds: 2),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmDialog(
          title: '确定删除会话吗？',
          content: '服务器不会保存聊天记录，删除之后聊天记录无法还原！',
          onConfirm: () => {deleteConversation(context)},
          onCancel: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // 显示长按菜单
  void _showLongPressMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("删除会话"),
                onTap: () {
                  // 删除会话的逻辑
                  print('Delete conversation');
                  _showLogoutConfirm(context);
                },
              ),
              // ListTile(
              //   leading: Icon(Icons.info_outline, color: Colors.blue),
              //   title: Text("查看详情"),
              //   onTap: () {
              //     // 跳转到会话详情页面的逻辑
              //     print('View conversation details');
              //     Navigator.pop(context);
              //   },
              // ),
              // ListTile(
              //   leading: Icon(Icons.notifications_off, color: Colors.orange),
              //   title: Text("关闭通知"),
              //   onTap: () {
              //     // 关闭通知的逻辑
              //     print('Mute notifications');
              //     Navigator.pop(context);
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,  // 允许子组件超出Stack范围
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              AppConfigs.getResourceUrl(conversation.peerAvatar),
              width: 44,
              height: 44,
              fit: BoxFit.cover,
            ),
          ),
          if (conversation.unreadCount > 0) // 判断是否有未读消息
            Positioned(
              right: 0, // 距离右边界为0，确保在头像的右上角
              top: 0,   // 距离顶部为0，确保在头像的右上角
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle, // 圆形背景
                ),
                constraints: BoxConstraints(minWidth: 20, minHeight: 20), // 确保容纳数字
                child: Center(
                  child: Text(
                    conversation.unreadCount > 99
                        ? '99+' // 如果大于99，显示99+
                        : conversation.unreadCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conversation.peerNickname,
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
      ),
      subtitle: Text(
        conversation.lastMessage ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              TimeUtils.formatSmartTime(conversation.lastMessageTime),
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      onTap: () {
        Navigator.push(
            context, slideTransitionTo(ChatPage(
            peerUser: PeerUser(id: conversation.peerId, nickname: conversation.peerNickname, avatarUrl: conversation.peerAvatar),
        conversation: conversation,
        )));
      },
      onLongPress: () {
        // 长按事件调用菜单
        _showLongPressMenu(context);
      },
    );
  }
}
