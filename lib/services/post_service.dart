import 'dart:io';

import 'package:dio/dio.dart';

import '../config/app_configs.dart';
import '../models/page/post_page.dart';

class PostService {
  static const String _baseUrl = '${AppConfigs.baseUrl}/api/posts';

  static Future<PostPage> getPosts({int page = 1, int size = 6, String? ownerId, String? id}) async {
    final Dio dio = Dio(BaseOptions(
      baseUrl: '$_baseUrl/list',
      headers: {
        'Authorization': await AppConfigs.getTokenHeader(), // 添加 Authorization header
      },
    ));
    try {
      final response = await dio.get(
        '$_baseUrl/list',
        queryParameters: {
          'page': page,
          'size': size,
          'id': id ?? '', // 如果 id 为 null，则传递空字符串
          'ownerId': ownerId ?? ''
        },
      );

      if (response.statusCode == 200) {
        // 获取 'data' 中的数据
        final data = response.data['data'];

        // 使用 PostPage.fromJson 解析数据
        final postPage = PostPage.fromJson(data);

        return postPage;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  static Future<Map<String, dynamic>?> publishPost({
    required String title,
    String? content,
    required List<File> images,
  }) async {
    final Dio dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': await AppConfigs.getTokenHeader(),  // 获取 Authorization header
      },
    ));

    try {
      // 创建 FormData 进行文件上传
      FormData formData = FormData.fromMap({
        'title': title,
        'content': content,
        // 将图片转化为 MultipartFile
        'images': await Future.wait(images.map((image) async {
          return await MultipartFile.fromFile(image.path, filename: image.uri.pathSegments.last);
        })),
      });

      // 发送 POST 请求
      final response = await dio.post('/publish', data: formData);

      if (response.statusCode == 200) {
        // 发布成功的逻辑
        print('发布成功');
        return response.data;
      } else {
        throw Exception('Failed to publish post');
      }
    } catch (e) {
      throw Exception('Error publishing post: $e');
    }
  }
}
