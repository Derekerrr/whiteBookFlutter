import 'package:drift/drift.dart';
import 'package:easy_chat/models/peer_user.dart';
import 'package:easy_chat/store/login_user_storage.dart';
import 'package:easy_chat/utils/time_utils.dart';
import 'package:flutter/material.dart';
import '../database/chat_database.dart';
import '../database/instance/chat_database_instance.dart';

class ConversationProvider extends ChangeNotifier {
  final List<ChatConversation> _conversations = [];

  List<ChatConversation> get conversations => _conversations;

  // 设置会话列表
  void setConversations(List<ChatConversation> conversations) {
    _conversations.clear();
    _conversations.addAll(conversations);
    notifyListeners();
  }

  int get totalUnreadCount {
    return _conversations.fold(0, (sum, conversation) {
      return sum + conversation.unreadCount;
    });
  }

  // 增加会话
  void addConversations(List<ChatConversation> conversations) {
    _conversations.addAll(conversations);
    notifyListeners();
  }

  void addConversation(ChatConversation conversation) {
    _conversations.insert(0, conversation);
    notifyListeners();
  }

  // 更新某个会话
  Future<void> updateConversation(ChatConversation updatedConversation) async {
    final db = await ChatDatabaseInstance.getInstance();  // 获取数据库实例
    db.updateConversationById(updatedConversation.id, updatedConversation);

    final index = _conversations.indexWhere((c) => c.id == updatedConversation.id);
    if (index != -1) {
      _conversations[index] = updatedConversation;
      sortConversationsByTime();
      notifyListeners();
    }
  }

  // 清空会话列表
  void clear() {
    _conversations.clear();
    notifyListeners();
  }

  ChatConversation? getConversationWithPeer(int userId, int peerId) {
    try {
      // 使用 firstWhere 查找第一个符合条件的会话
      return _conversations.firstWhere(
            (conversation) =>
        conversation.ownerId == userId && conversation.peerId == peerId,
      );
    } catch (e) {
      // 如果没有找到符合条件的会话，返回 null
      return null;
    }
  }

  // 删除某个会话
  Future<void> deleteConversation(int conversationId) async {
    final db = await ChatDatabaseInstance.getInstance();  // 获取数据库实例
    await db.deleteMessagesByConversationId(conversationId.toString()); // 删除该会话的所有消息
    await db.deleteConversationById(conversationId);  // 删除数据库中的会话

    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      _conversations.removeAt(index);  // 从内存中移除该会话
      notifyListeners();  // 通知UI更新
    }
  }

  // 创建会话
  Future<ChatConversation?> createNewConversation(PeerUser loginUser, PeerUser peerUser) async {
    final db = await ChatDatabaseInstance.getInstance();  // 获取数据库实例

    ChatConversation? conversation = await db.getConversationByOwnerAndPeerId(loginUser.id, peerUser.id);

    if (conversation == null) {
      // 创建新的会话
      final newConversation = ChatConversationsCompanion(
        ownerId: Value(loginUser.id),
        peerId: Value(peerUser.id),
        type: Value('private'),
        lastMessage: Value(null),
        lastMessageTime: Value(TimeUtils.getTimeNow()),
        unreadCount: Value(0),
        isPinned: Value(false),
        peerNickname: Value(peerUser.nickname),
        peerAvatar: Value(peerUser.avatarUrl!),
        isDeleted: Value(false),
      );

      // 插入会话到数据库
      conversation = await db.insertConversation(newConversation);
    }

    _conversations.add(conversation);  // 将新会话添加到会话列表

    sortConversationsByTime();  // 排序会话列表

    notifyListeners();  // 通知更新
    // 返回新创建的会话
    return conversation;
  }


  void sortConversationsByTime() {
    _conversations.sort((a, b) {
      // 比较时间，降序排列
      // 如果 a 的 lastMessageTime 比 b 的晚，返回负值（表示 a 排在前面）
      // 如果 a 的 lastMessageTime 比 b 的早，返回正值（表示 b 排在前面）
      // 如果相同，返回 0（表示相对位置不变）
      return b.lastMessageTime.compareTo(a.lastMessageTime);
    });
  }

  void loadConversations() {
    _conversations.clear();
    // 初始化数据库
    ChatDatabaseInstance.getInstance().then((db) async {
      // 加载历史会话
      try {
        print('try to init conversations');
        int? userId = await LoginUserStorage.getUserId();
        final conversations = await db.getConversationsByOwnerId(
            userId!, 10000, 0
        ); // 获取所有会话
        _conversations.addAll(conversations);
        print('init conversation successfully, length is ${_conversations.length}');
        notifyListeners();  // 通知更新
      } catch (e) {
        print('Error loading conversations: $e');
        // 你可以根据需要在此处显示一个错误提示
      }
    });
  }
}
