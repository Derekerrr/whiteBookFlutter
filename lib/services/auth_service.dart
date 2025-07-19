import 'package:dio/dio.dart';
import 'package:easy_chat/config/app_configs.dart';

class AuthService {
  static final String localHost = 'http://${AppConfigs.serverIp}:${AppConfigs.serverPort}/api'; // Android 模拟器专用
  static final Dio _dio = Dio(BaseOptions(baseUrl: localHost));

  /// 登录请求
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      print(res);

      if (res.statusCode == 200) {
        return res.data;
      } else {
        return res.data['message'] ?? "Unknown error";
      }
    } on DioException catch (e) {
      throw Exception('Error login: $e');
    } catch (e) {
      throw Exception('Error login exception: $e');
    }
  }

  /// 注册请求
  static Future<Map<String, dynamic>?> register(String username, String password, String nickname, String gender, String avatarPath) async {
    try {
      // 构建表单数据
      FormData formData = FormData.fromMap({
        'username': username,
        'password': password,
        'nickname': nickname,
        'gender': gender,
        // 如果头像路径不为空，添加文件
        if (avatarPath.isNotEmpty) 'avatar': await MultipartFile.fromFile(avatarPath),
      });

      // 发送 POST 请求到注册接口
      final response = await _dio.post('/auth/register', data: formData);

      // 处理注册成功的返回数据
      if (response.statusCode == 200) {
        return response.data;  // 返回 data
      } else {
        print("Registration failed: ${response.data}");
        // 处理其他失败的返回
        return response.data;
      }
    } catch (e) {
      print("Error during registration: $e");
      // 错误处理，例如显示网络错误等
    }
    return null;
  }

  // 检查昵称占用情况
  static Future<bool> checkUsernameExists(String username) async {
    try {
      final res = await _dio.get('/auth/check-username', queryParameters: {
        'username': username,
      });
      return res.data['taken'] ?? false;
    } on DioException catch (e) {
      print('Error checking username: ${e.message}');
      return false;
    }
  }

  // 检查token是否有效
  static Future<bool> checkTokenValid(String token) async {
    try {
      final response = await _dio.get('/auth/check-token', queryParameters: {
        'token': token,
      });
      // 处理注册成功的返回数据
      if (response.statusCode == 200) {
        return response.data['code'].toString() == '200';  // 返回 data
      } else {
        return false;
      }
    } on DioException catch (e) {
      print('Error checking username: ${e.message}');
      return false;
    }
  }
}
