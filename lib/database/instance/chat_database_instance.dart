import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../chat_database.dart';

class ChatDatabaseInstance {
  static ChatDatabase? _instance;

  static Future<ChatDatabase> getInstance() async {
    if (_instance == null) {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'chat.sqlite'));
      _instance = ChatDatabase(NativeDatabase(file));
    }
    return _instance!;
  }

  static ChatDatabase get current {
    if (_instance == null) {
      throw Exception('ChatDatabase not initialized. Call getInstance() first.');
    }
    return _instance!;
  }
}
