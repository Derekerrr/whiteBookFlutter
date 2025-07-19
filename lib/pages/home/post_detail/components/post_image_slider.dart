import 'package:easy_chat/config/app_configs.dart';
import 'package:easy_chat/models/post_image.dart';
import 'package:easy_chat/pages/home/post_detail/components/photo_preview_page.dart';
import 'package:flutter/material.dart';

class PostImageSlider extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoPreviewPage(
                        images: images,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  AppConfigs.getResourceUrl(images[index].imageUrl),
                  fit: BoxFit.cover,
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
            images.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: currentPage == index ? 8 : 4,
              height: currentPage == index ? 8 : 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentPage == index
                    ? Colors.black
                    : Colors.grey[400],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
