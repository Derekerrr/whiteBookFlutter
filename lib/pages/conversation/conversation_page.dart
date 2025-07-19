import 'package:easy_chat/provider/conversation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'common/chat_list_item.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final conversationList = context.watch<ConversationProvider>().conversations;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('消息', style: TextStyle(fontWeight: FontWeight.bold,),),
        elevation: 0.5,
      ),
      body: ListView.separated(
        itemCount: conversationList.length + 1,
        separatorBuilder: (_, __) =>
            const Divider(height: 0.1, indent: 77, endIndent: 20),
        itemBuilder: (context, index) {
          if (index < conversationList.length) {
            return ChatListItem(conversation: conversationList[index]);
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  '-- 共${conversationList.length}个会话 --',
                  style: TextStyle(
                      color: Colors.black45
                  ),
                ),
              ),
            );
          }
        },
      )
    );
  }
}
