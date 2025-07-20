import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:easy_chat/config/app_configs.dart';
import 'package:easy_chat/models/peer_user.dart';
import 'package:easy_chat/services/user_service.dart';
import 'package:easy_chat/store/login_user_storage.dart';
import 'package:easy_chat/store/token_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../database/chat_database.dart';
import '../database/instance/chat_database_instance.dart';
import '../provider/conversation_provider.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManager() => _instance;

  late ConversationProvider _conversationProvider;

  WebSocketManager._internal();

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  final Duration _heartbeatInterval = Duration(seconds: 15);
  final Duration _reconnectInterval = Duration(seconds: 3);

  String? _token;
  String? _url;
  bool _isConnected = false;

  // 用于消息事件流
  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();

  // 允许多个订阅者接收 WebSocket 消息
  Stream<ChatMessage> get messageStream => _messageController.stream;

  Future<void> init(ConversationProvider conversationProvider) async {
    // 初始化conversationProvider
    _conversationProvider = conversationProvider;
  }

  Future<void> connect() async {
    _token = await TokenStorage.getToken();
    _url = 'ws://${AppConfigs.serverIp}:${AppConfigs.serverPort}/ws?token=$_token';
    print('start to connect ws server...');
    if (_token == null) {
      print('token is null, now return');
      return;
    }
    if (_isConnected) {
      print('connect is alive, now return');
      return;
    }
    _channel = WebSocketChannel.connect(Uri.parse(_url!));
    _isConnected = true;
    print('ws server connected!');

    _channel!.stream.listen(
      _onMessage,
      onDone: _onDisconnected,
      onError: (error) {
        print("WebSocket error: $error");
        _onDisconnected();
      },
    );

    _startHeartbeat();
  }

  void _onMessage(dynamic message) {
    print('Received: $message');
    try {
      final decoded = jsonDecode(message);
      if (decoded['type'] == 'PEER_MESSAGE') {
        // 处理收到私信
        _handlerPeerMessage(decoded);
      }
    } catch (e) {
      print("Failed to decode message: $e");
    }
  }

  void _handlerPeerMessage(dynamic message) async {
    final peerMsg = message['data'];

    String senderId = peerMsg['senderId'].toString();
    String receiverId = peerMsg['receiverId'].toString();

    ChatConversation? conversation = _conversationProvider.getConversationWithPeer(int.parse(receiverId), int.parse(senderId));
    // 如果不存在于该用户的对话需要重新创建
    if (conversation == null) {
      // 获取对方用户信息
      PeerUser? peerUser = await UserService.getUserById(senderId);
      PeerUser? loginUser = await LoginUserStorage.getUser();
      conversation = await _conversationProvider.createNewConversation(loginUser!, peerUser!);
    }

    final db = await ChatDatabaseInstance.getInstance();  // 获取数据库实例
    ChatMessage? inertMessage = await db.insertMessage(ChatMessagesCompanion.insert(
      conversationId: conversation!.id.toString(),
      senderId: peerMsg['senderId'].toString(),
      receiverId: peerMsg['receiverId'].toString(),
      content: drift.Value(peerMsg['content']),
      imageUrl: drift.Value(peerMsg['imageUrl']),
      isSender: false,
      timestamp: DateTime.parse(peerMsg['sentAt']),
    ));

    // 更新会话状态
    ChatConversation updateConversation = conversation.copyWith(
      lastMessage: drift.Value(inertMessage.imageUrl != null ? '[图片]' : inertMessage.content),
      lastMessageTime: inertMessage.timestamp,
      unreadCount: conversation.unreadCount + 1
    );
    _conversationProvider.updateConversation(updateConversation);

    // 将消息通过 StreamController 分发给订阅者
    _messageController.add(inertMessage);
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      sendJson({'type': 'PING', 'data': 'ping'});
    });
  }

  void _onDisconnected() {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _channel = null;

    _startReconnect();
  }

  void _startReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;

    _reconnectTimer = Timer.periodic(_reconnectInterval, (_) {
      if (!_isConnected) {
        print('Trying to reconnect...');
        connect();
      } else {
        _reconnectTimer?.cancel();
      }
    });
  }

  void sendSting(String message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(message);
    }
  }

  void sendJson(Map<String, dynamic> data) {
    sendSting(jsonEncode(data));
  }

  void close() {
    print('start to close ws link...');
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    print('start to close ws over!');
  }

  bool get isConnected => _isConnected;
}
