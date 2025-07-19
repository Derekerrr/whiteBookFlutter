import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_chat/config/app_configs.dart';

class MessageService {
  static const String _baseUrl = '${AppConfigs.baseUrl}/api/messages/send';

  static final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  static Future<Map<String, dynamic>?> sendMessageWithDio({
    required String receiverId,
    required String content,
    File? imageFile,
  }) async {
    try {
      // 构建表单数据
      FormData formData = FormData.fromMap({
        'receiverId': receiverId,
        'content': content,
        if (imageFile != null)
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });

      final response = await _dio.post(_baseUrl, // ✅ 替换成你的后端地址
        data: formData,
        options: await AppConfigs.getMultipartOptions()
      );

      if (response.statusCode == 200) {
        print('✅ 消息发送成功: ${response.data}');
        return response.data;
      } else {
        print('❌ 消息发送失败: ${response.statusCode}, ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ 发送消息异常: $e');
      rethrow;
    }
  }
}
