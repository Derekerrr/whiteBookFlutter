import 'dart:io';
import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:easy_chat/models/peer_user.dart';
import 'package:easy_chat/pages/user/peer_user_page.dart';
import 'package:easy_chat/provider/conversation_provider.dart';
import 'package:easy_chat/provider/user_provider.dart';
import 'package:easy_chat/utils/page_slide.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../database/chat_database.dart';
import '../../../database/instance/chat_database_instance.dart';
import '../../../services/message_service.dart';
import '../../../utils/custom_dialog.dart';
import '../../../utils/time_utils.dart';
import 'components/date_separator.dart';
import 'components/image_preview.dart';
import 'components/input_area.dart';
import 'components/message_bubble.dart';
import '../../../services/websocket_manager.dart';

class ChatPage extends StatefulWidget {
  final ChatConversation conversation;
  final PeerUser peerUser;

  const ChatPage({super.key, required this.conversation, required this.peerUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // 分页
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  final int _pageSize = 20;
  int? startId;

  File? _selectedImage;
  late ChatDatabase _db;
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();

    ChatDatabaseInstance.getInstance().then((db) {
      _db = db;
      _loadMessages();
    });

    _scrollController.addListener(() {
      if (_scrollController.offset <= _scrollController.position.minScrollExtent + 100 && !_isLoading && _hasMore) {
        _loadMessages();
      }
    });

    _messageSubscription = WebSocketManager().messageStream.listen((message) {
      if (message.senderId != widget.peerUser.id.toString()) return;
      setState(() => _messages.add(message));
      _scrollToBottom();
      // 更新会话
      if (mounted) {
        context.read<ConversationProvider>().updateConversation(widget.conversation.copyWith(unreadCount: 0));
      }
    });

    // WebSocketManager().connect();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    final offset = _page * _pageSize;
    final localMessages = await _db.getMessagesPaged(widget.conversation.id.toString(), _pageSize, offset, startId);

    if (localMessages.isEmpty) {
      _hasMore = false;
    } else {
      setState(() {
        _messages.insertAll(0, localMessages.reversed);
        _page++;
      });

      if (_page == 1) {
        _scrollToBottom();
      }

      if (startId != null && localMessages.isNotEmpty) {
        startId = localMessages[0].id;
      }
    }

    setState(() => _isLoading = false);

    // 更新会话
    if (mounted) {
      context.read<ConversationProvider>().updateConversation(widget.conversation.copyWith(unreadCount: 0));
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty && _selectedImage == null) {
      CustomDialog.show(context: context, message: 'Cannot send empty message！', buttonText: 'OK', isSuccess: false);
      return;
    }

    final text = _controller.text.trim();
    final image = _selectedImage;

    ChatMessage? inertMessage = await _db.insertMessage(ChatMessagesCompanion.insert(
      conversationId: widget.conversation.id.toString(),
      senderId: context.read<UserProvider>().user.id.toString(),
      receiverId: widget.peerUser.id.toString(),
      content: drift.Value(text),
      imageUrl: drift.Value(image?.path),
      isSender: true,
      timestamp: TimeUtils.getTimeNow(),
    ));

    setState(() {
      _messages.add(inertMessage);
      _controller.clear();
      _selectedImage = null;
    });

    _scrollToBottom();

    // 更新会话
    if (mounted) {
      context.read<ConversationProvider>().updateConversation(widget.conversation.copyWith(
        lastMessageTime: inertMessage.timestamp,
        lastMessage: drift.Value(inertMessage.imageUrl != null ? '[图片]' : inertMessage.content)
      ));
    }

    setState(() => _isLoading = true);

    try {
      await MessageService.sendMessageWithDio(
        receiverId: widget.peerUser.id.toString(),
        content: text,
        imageFile: image,
      );
    } catch (e) {
      print('❌ Send failed: $e');
      CustomDialog.show(context: context, message: '发送失败，请重试', buttonText: 'OK', isSuccess: false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  List<Widget> _buildMessageList() {
    List<Widget> widgets = [];
    DateTime? lastDate;

    for (int i = 0; i < _messages.length; i++) {
      final message = _messages[i];

      if (lastDate == null || !TimeUtils.isSameDay(lastDate, message.timestamp)) {
        widgets.add(DateSeparator(date: message.timestamp));
        lastDate = message.timestamp;
      }

      bool showTime = true;
      if (i > 0 && message.timestamp.difference(_messages[i - 1].timestamp).inMinutes < 1) {
        showTime = false;
      }

      widgets.add(MessageBubble(message: message, showTime: showTime));
    }

    return widgets;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.peerUser.nickname),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => {
                Navigator.push(
                    context, slideTransitionTo(PeerUserPage(userId: widget.peerUser.id.toString()))
                )
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: const Icon(Icons.double_arrow, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              reverse: false,
              padding: const EdgeInsets.all(16),
              children: _buildMessageList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_selectedImage != null)
                  ImagePreview(image: _selectedImage!, onRemove: () => setState(() => _selectedImage = null)),
                InputArea(
                  controller: _controller,
                  onPickImage: _pickImage,
                  onSend: _sendMessage,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
