import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import './entity/conversation.dart'; // 你的 Conversation 表结构
import './entity/message.dart'; // 你的 ChatMessage 表结构

part 'chat_database.g.dart';

@DriftDatabase(tables: [ChatConversations, ChatMessages])
class ChatDatabase extends _$ChatDatabase {
  ChatDatabase(NativeDatabase nativeDatabase) : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // 会话插入
  Future<ChatConversation> insertConversation(ChatConversationsCompanion conversation) async {
    print('start to insert a new conversation: ${conversation.toString()}');
    return await into(chatConversations).insertReturning(conversation);
  }

  // 根据 ID 更新会话
  Future<int> updateConversationById(int id, ChatConversation conversation) async {
    print('Start to update conversation with id: $id');

    // 更新指定ID的会话数据
    return await (update(chatConversations)
      ..where((tbl) => tbl.id.equals(id))) // 根据 ID 过滤
        .write(conversation); // 更新数据
  }


  // 根据 ID 删除会话
  Future<void> deleteConversationById(int id) async {
    await (delete(chatConversations)..where((tbl) => tbl.id.equals(id))).go();
  }

  // 根据 ownerId 和 peerId 查询会话（支持分页）
  Future<List<ChatConversation>> getConversationsPaged(int ownerId, int peerId, int limit, int offset) async {
    return (select(chatConversations)
      ..where((tbl) => tbl.ownerId.equals(ownerId) & tbl.peerId.equals(peerId))
      ..limit(limit, offset: offset))
        .get();
  }

  // 根据 ownerId 和 peerId 查询会话（支持分页）
  Future<List<ChatConversation>> getConversationsByOwnerId(int ownerId, int limit, int offset) async {
    return (select(chatConversations)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.lastMessageTime, mode: OrderingMode.desc)]) // 根据 lastMessageTime 降序排序
      ..limit(limit, offset: offset))
        .get();
  }

  // 根据 peerNickname 和 lastMessage 模糊查询会话
  Future<List<ChatConversation>> searchConversations(String peerNickname, String lastMessage) async {
    return (select(chatConversations)
      ..where((tbl) =>
      tbl.peerNickname.like('%$peerNickname%') &
      tbl.lastMessage.like('%$lastMessage%')))
        .get();
  }

  // 消息插入
  Future<ChatMessage> insertMessage(ChatMessagesCompanion message) async {
    final insertedMessage = await into(chatMessages).insertReturning(message);
    return insertedMessage;
  }

  // 根据 conversationId 分页查询消息
  Future<List<ChatMessage>> getMessagesPaged(String conversationId, int limit, int offset, int? start) async {
    final query = select(chatMessages)
      ..where((tbl) => tbl.conversationId.equals(conversationId))
      ..limit(limit, offset: offset)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.id, mode: OrderingMode.desc)]);

    if (start != null) {
      query.where((tbl) => tbl.id.isSmallerThanValue(start)); // 如果 start 不为空，加入 id < start 条件
    }

    return query.get();
  }

  // 根据 ID 删除消息
  Future<void> deleteMessageById(int id) async {
    await (delete(chatMessages)..where((tbl) => tbl.id.equals(id))).go();
  }

  // 根据 conversationId 删除消息
  Future<void> deleteMessagesByConversationId(String conversationId) async {
    await (delete(chatMessages)
      ..where((tbl) => tbl.conversationId.equals(conversationId)))
        .go();
  }

  // 根据 ownerId 和 peerId 查找会话
  Future<ChatConversation?> getConversationByOwnerAndPeerId(int ownerId, int peerId) async {
    print('start to query conversation in db, ownerId: $ownerId, peerId $peerId');
    return await (select(chatConversations)
      ..where((tbl) => tbl.ownerId.equals(ownerId) & tbl.peerId.equals(peerId)))
        .getSingleOrNull();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'chat.sqlite'));
    //
    // if (await file.exists()) {
    //   await file.delete();
    // }

    return NativeDatabase(file);
  });
}
