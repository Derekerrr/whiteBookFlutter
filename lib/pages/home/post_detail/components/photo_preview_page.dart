import 'package:flutter/material.dart';

import '../../../../config/app_configs.dart';
import '../../../../models/post_image.dart';

class PhotoPreviewPage extends StatefulWidget {
  final List<PostImage> images;
  final int initialIndex;

  const PhotoPreviewPage({
    super.key,
    required this.initialIndex, required this.images,
  });

  @override
  State<PhotoPreviewPage> createState() => _PhotoPreviewPageState();
}

class _PhotoPreviewPageState extends State<PhotoPreviewPage> {
  late PageController _controller;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
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
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (_, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    AppConfigs.getResourceUrl(widget.images[index].imageUrl),
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 40,
            child: Text(
              '${currentIndex + 1} / ${widget.images.length}',
              style: const TextStyle(color: Colors.white70),
            ),
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
