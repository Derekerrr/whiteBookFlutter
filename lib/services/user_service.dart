import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_chat/models/peer_user.dart';
import '../config/app_configs.dart';

class UserService {
  static final Dio dio = Dio(BaseOptions(baseUrl: AppConfigs.baseUrl, contentType: 'application/json'));

  /// 获取用户信息
  static Future<PeerUser?> getUserById(String userId) async {
    try {
      final headers = {
        'Authorization': await AppConfigs.getTokenHeader(),  // 如果需要传 token
      };

      final response = await dio.get(
        '/api/users/$userId',  // 获取用户信息的接口
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return PeerUser.fromJson(response.data['data']);  // 返回用户数据（Map 类型）
      } else {
        print('Failed to fetch user: ${response.data}');
        return null;  // 请求失败，返回 null
      }
    } catch (e) {
      print('Error while fetching user: $e');
      throw Exception('Error while fetching user');  // 请求错误
    }
  }

  /// 更新用户信息
  static Future<PeerUser?> updateUser({
    String? nickname,
    String? gender,
    String? bio,
    File? avatar,
    File? background,
  }) async {
    try {
      // 获取请求头中的 token
      final headers = {
        'Authorization': await AppConfigs.getTokenHeader(),
      };

      // 准备要发送的文件
      FormData formData = FormData.fromMap({
        'nickname': nickname ?? '',
        'gender': gender ?? '',
        'bio': bio ?? '',
        if (avatar != null) 'avatar': await MultipartFile.fromFile(avatar.path),
        if (background != null) 'background': await MultipartFile.fromFile(background.path),
      });

      // 发送 PUT 请求来更新用户信息
      final response = await dio.put(
        '/api/users/update', // 后端接口路径
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        if (response.data['code'].toString() == '200') {
          // 如果请求成功，返回更新后的用户数据
          return PeerUser.fromJson(response.data['data']);
        }
        return null;
      } else {
        print('Failed to update user: ${response.data}');
        return null; // 请求失败
      }
    } catch (e) {
      print('Error while updating user: $e');
      throw Exception('Error while updating user');
    }
  }
}
