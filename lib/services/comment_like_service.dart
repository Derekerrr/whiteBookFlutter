import 'package:dio/dio.dart';
import '../config/app_configs.dart';

class CommentLikeService {
  static final Dio dio = Dio(BaseOptions(baseUrl: '${AppConfigs.baseUrl}', contentType: 'application/json'));

  /// 点赞
  static Future<bool> likeComment(String commentId) async {
    try {
      final headers = {
        'Authorization': await AppConfigs.getTokenHeader(),
      };

      final response = await dio.post(
        '/api/comments/$commentId/like',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final code = data['code'] ?? 500;

        if (code == 200) {
          print('Liked comment $commentId successfully.');
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
      print('Error while liking comment: $e');
      throw Exception('Error while liking comment');
    }
  }

  /// 取消点赞
  static Future<bool> unlikeComment(String commentId) async {
    try {
      final headers = {
        'Authorization': await AppConfigs.getTokenHeader(),
      };

      final response = await dio.post(
        '/api/comments/$commentId/unlike',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final code = data['code'] ?? 500;

        if (code == 200) {
          print('Unliked commentId $commentId successfully.');
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
      print('Error while unliking comment: $e');
      throw Exception('Error while unliking comment');
    }
  }
}
