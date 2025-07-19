import 'package:dio/dio.dart';

import '../store/token_storage.dart';

class AppConfigs {
  static const String serverIp = '8.138.11.95';
  // static const String serverIp = '192.168.1.40';

  static const String serverPort = '9090';
  // static const String serverPort = '8080';

  static const String baseUrl = "http://$serverIp:$serverPort";

  // 服务器只保存资源相对路径
  static String getResourceUrl(String url) {
    return "http://$serverIp:$serverPort$url";
  }

  static Future<Options> getMultipartOptions() async {
    return Options(
      headers: {
    'Authorization': 'Bearer ${await TokenStorage.getToken()}', // ✅ 添加认证 token
    'Content-Type': 'multipart/form-data',
    },
    );
  }

  static Future<Options> getJsonOptions() async {
    return Options(
      headers: {
        'Authorization': 'Bearer ${await TokenStorage.getToken()}', // ✅ 添加认证 token
        'Content-Type': 'application/json',
      },
    );
  }

  static Future<String> getTokenHeader() async {
    return 'Bearer ${await TokenStorage.getToken()}';
  }
}