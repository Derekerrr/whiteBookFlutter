import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../config/app_configs.dart';
import '../../../../models/type/app_enums.dart';

class ChatPhotoPreviewPage extends StatefulWidget {
  final String url;
  final ImageSourceType type;

  const ChatPhotoPreviewPage({
    super.key, required this.url, required this.type,
  });

  @override
  State<ChatPhotoPreviewPage> createState() => _ChatPhotoPreviewPageState();
}

class _ChatPhotoPreviewPageState extends State<ChatPhotoPreviewPage> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            itemCount: 1,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (_, index) {
              if (widget.type == ImageSourceType.server) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      AppConfigs.getResourceUrl(widget.url),
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              } else {
                return InteractiveViewer(
                  child: Center(
                    child: Image.file(
                      File(widget.url),
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              }
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
