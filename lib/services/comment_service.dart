import 'package:dio/dio.dart';
import 'package:easy_chat/config/app_configs.dart';
import '../models/dto/post_comment_request.dart';
import '../models/page/comment_page.dart';
import '../models/post_comments.dart';

class CommentService {
  // 静态 Dio 实例
  static final Dio dio = Dio(BaseOptions(baseUrl: '${AppConfigs.baseUrl}/api/comments', contentType: 'application/json'));

  // 静态方法：发布评论
  static Future<Comment> publishComment(PostCommentRequest request) async {
    try {
      // 发送 POST 请求
      final response = await dio.post(
        '/publish',  // 假设发布评论的接口
        data: request.toJson(),  // 确保请求体是 JSON 格式
        options: await AppConfigs.getJsonOptions(),  // 其他请求配置
      );

      if (response.statusCode == 200) {
        // 假设返回的数据格式是：{ "data": { ... } }
        if (response.data['code'].toString() == '200') {
          final commentData = response.data['data'];
          // 将返回的 JSON 数据转为 Comment 实例
          return Comment.fromJson(commentData);
        }
        throw Exception('Failed to send comment:${response.data['message']}');
      } else {
        throw Exception('Failed to send comment');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error occurred while publishing comment');
    }
  }

  // 静态方法：获取评论列表，支持分页
  static Future<CommentPage> getComments({
    required String postId,
    int pageNum = 1,  // 默认第一页
    int pageSize = 5,  // 默认每页 10 条
    int replyPageNum = 1,  // 默认子评论第一页
    int replyPageSize = 2,  // 默认每页 5 条子评论
    String? parentId,  // 可选参数，筛选某个父评论的子评论
  }) async {
    try {
      // 请求头，添加认证 token
      final headers = {
        'Authorization': await AppConfigs.getTokenHeader(),
      };

      // 请求参数，支持分页及可选的 parentId 参数
      final queryParams = {
        'pageNum': pageNum,
        'pageSize': pageSize,
        'replyPageNum': replyPageNum,
        'replyPageSize': replyPageSize,
        if (parentId != null) 'parentId': parentId,
      };

      // 发送 GET 请求
      final response = await dio.get(
        '/post/$postId/comments',  // 使用实际的评论接口路径
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      // 处理响应并返回 CommentPage
      if (response.statusCode == 200) {
        final responseData = response.data;
        return CommentPage.fromJson(responseData);
      } else {
        print('Failed to load comments: ${response.data}');
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error occurred while loading comments');
    }
  }
}