import 'package:drift/drift.dart';

// part 'conversation.g.dart';

@DataClassName('ChatConversation')
class ChatConversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ownerId => integer()();  // 当前用户ID（自己）
  IntColumn get peerId => integer()();  // 对方用户ID

  // 设置 ownerId 和 peerId 组合唯一
  @override
  Set<Column> get primaryKey => {ownerId, peerId};  // 将组合列作为唯一约束（主键）

  TextColumn get type => text().withDefault(Constant('private'))();  // 会话类型（私聊、群聊等）
  TextColumn get lastMessage => text().nullable()();  // 最后一条消息内容
  DateTimeColumn get lastMessageTime => dateTime()();  // 最后一条消息的时间
  IntColumn get unreadCount => integer().withDefault(Constant(0))();  // 未读消息数
  BoolColumn get isPinned => boolean().withDefault(Constant(false))();  // 是否置顶
  TextColumn get peerNickname => text()();  // 对方昵称
  TextColumn get peerAvatar => text()();  // 对方头像URL
  BoolColumn get isDeleted => boolean().withDefault(Constant(false))();  // 是否已删除
}
