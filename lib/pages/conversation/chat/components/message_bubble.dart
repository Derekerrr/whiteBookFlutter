import 'dart:io';

import 'package:easy_chat/config/app_configs.dart';
import 'package:easy_chat/database/chat_database.dart';
import 'package:easy_chat/models/type/app_enums.dart';
import 'package:flutter/material.dart';
import '../../../../utils/time_utils.dart';
import 'chat_photo_preview_page.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTime;

  const MessageBubble({
    super.key,
    required this.message,
    required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.7;
    return Align(
      alignment: message.isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        message.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: message.isSender ? Colors.green[400] : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imageUrl != null && !message.isSender)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPhotoPreviewPage(
                              url: message.imageUrl!, type: ImageSourceType.server,
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        AppConfigs.getResourceUrl(message.imageUrl!), // 加载网络图片
                        fit: BoxFit.cover,
                        height: 160,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 160,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            height: 160,
                            child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                          );
                        },
                      ),
                    ),
                  ),
                if (message.imageUrl != null && message.isSender)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPhotoPreviewPage(
                              url: message.imageUrl!, type: ImageSourceType.local,
                            ),
                          ),
                        );
                      },
                      child: Image.file(
                        File(message.imageUrl!),
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            height: 160,
                            child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                          );
                        },
                      ),
                    ),
                  ),
                if (message.imageUrl != null && message.content != null)
                  const SizedBox(height: 6),
                if (message.content != null && message.content!.isNotEmpty)
                  Text(
                    message.content.toString(),
                    style: TextStyle(
                      color: message.isSender ? Colors.white : Colors.black,
                    ),
                  ),
              ],
            ),
          ),
          if (showTime)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
              child: Text(
                TimeUtils.formatSmartTime(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
