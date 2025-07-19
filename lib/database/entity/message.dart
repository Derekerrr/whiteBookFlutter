import 'package:drift/drift.dart';

// part 'chat_message.g.dart';

@DataClassName('ChatMessage')
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()(); // 消息ID
  TextColumn get conversationId => text()(); // 会话ID
  TextColumn get senderId => text()(); // 发送者ID
  TextColumn get receiverId => text()(); // 接收者ID
  TextColumn get content => text().nullable()(); // 消息内容
  TextColumn get imageUrl => text().nullable()(); // 图片URL
  BoolColumn get isSender => boolean()(); // 是否是发送者
  DateTimeColumn get timestamp => dateTime()(); // 时间戳
}
