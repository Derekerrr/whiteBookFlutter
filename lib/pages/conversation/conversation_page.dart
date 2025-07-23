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
        title: const Text('消息', style: TextStyle(fontWeight: FontWeight.w500,),),
        elevation: 0.5,
      ),
      body: ListView.builder(
        itemCount: conversationList.length + 1,
        itemExtent: 66, // 每个元素固定 60 高
        itemBuilder: (context, index) {
          if (index < conversationList.length) {
            return ChatListItem(conversation: conversationList[index]);
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
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
