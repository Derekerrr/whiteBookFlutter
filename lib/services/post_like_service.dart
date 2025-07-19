import 'package:dio/dio.dart';
import '../config/app_configs.dart';  // 替换为你项目实际的 AppConfigs 路径

class PostLikeService {
  static final Dio dio = Dio(BaseOptions(baseUrl: '${AppConfigs.baseUrl}', contentType: 'application/json'));

  /// 点赞
  static Future<bool> likePost(String postId) async {
    try {
      final headers = {
        'Authorization': await AppConfigs.getTokenHeader(),
      };

      final response = await dio.post(
        '/api/posts/$postId/like',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final code = data['code'] ?? 500;

        if (code == 200) {
          print('Liked post $postId successfully.');
          return true;
        } else {
          print('Business failed to like: ${data['message']}');
          return false;
        }
      } else {
        print('HTTP failed to like: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error while liking post: $e');
      throw Exception('Error while liking post');
    }
  }

  /// 取消点赞
  static Future<bool> unlikePost(String postId) async {
    try {
      final headers = {
        'Authorization': await AppConfigs.getTokenHeader(),
      };

      final response = await dio.post(
        '/api/posts/$postId/unlike',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final code = data['code'] ?? 500;

        if (code == 200) {
          print('Unliked post $postId successfully.');
          return true;
        } else {
          print('Business failed to unlike: ${data['message']}');
          return false;
        }
      } else {
        print('HTTP failed to unlike: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error while unliking post: $e');
      throw Exception('Error while unliking post');
    }
  }
}
