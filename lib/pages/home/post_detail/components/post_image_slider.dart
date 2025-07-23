import 'dart:async';

import 'package:easy_chat/config/app_configs.dart';
import 'package:easy_chat/models/post_image.dart';
import 'package:easy_chat/pages/home/post_detail/components/photo_preview_page.dart';
import 'package:flutter/material.dart';

class PostImageSlider extends StatefulWidget {
  final List<PostImage> images;
  final Function(int) onPageChanged;
  final int currentPage;

  const PostImageSlider({
    super.key,
    required this.onPageChanged,
    required this.currentPage,
    required this.images,
  });

  @override
  State<PostImageSlider> createState() => _PostImageSliderState();
}

class _PostImageSliderState extends State<PostImageSlider> {
  final Map<int, double> _aspectRatios = {};
  bool _isLoading = true;
  final double _maxHeightFactor = 0.6; // 图片高度最大占屏幕高度的比例

  @override
  void initState() {
    super.initState();
    _precacheImages();
  }

  Future<void> _precacheImages() async {
    for (var i = 0; i < widget.images.length; i++) {
      final url = AppConfigs.getResourceUrl(widget.images[i].imageUrl);
      final ImageStream stream = NetworkImage(url).resolve(ImageConfiguration.empty);
      final completer = Completer<void>();
      final listener = ImageStreamListener((ImageInfo info, bool _) {
        final width = info.image.width.toDouble();
        final height = info.image.height.toDouble();
        if (height != 0) {
          _aspectRatios[i] = width / height;
        } else {
          _aspectRatios[i] = 1.0;
        }
        completer.complete();
      }, onError: (dynamic error, StackTrace? stackTrace) {
        _aspectRatios[i] = 1.0; // 默认比例
        completer.complete();
      });

      stream.addListener(listener);
      await completer.future;
      stream.removeListener(listener);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 当前图片的宽高比，默认为 1.0（正方形）
    final aspectRatio = _aspectRatios[widget.currentPage] ?? 1.0;

    // 计算图片的最大高度，根据屏幕高度的某个比例（例如最大 80%）
    final maxHeight = screenHeight * _maxHeightFactor;

    // 计算当前图片应该展示的高度，确保图片高度不超过最大限制
    final containerHeight = (screenWidth / aspectRatio).clamp(0.0, maxHeight);

    return Column(
      children: [
        SizedBox(
          height: _isLoading ? 300 : containerHeight,
          width: double.infinity,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: widget.onPageChanged,
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoPreviewPage(
                        images: widget.images,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  AppConfigs.getResourceUrl(widget.images[index].imageUrl),
                  fit: BoxFit.contain,  // 保持图片比例完整展示
                  width: double.infinity,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.images.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: widget.currentPage == index ? 8 : 4,
              height: widget.currentPage == index ? 8 : 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.currentPage == index ? Colors.black : Colors.grey[400],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
