import 'package:intl/intl.dart';

class TimeUtils {
  // 格式化时间，返回类似 "09:42 PM" 的格式
  static String formatTimestamp(DateTime timestamp) {
    return DateFormat('hh:mm a').format(timestamp); // eg. 09:42 PM
  }

  // 格式化日期，返回类似 "2025-07-06" 的格式
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date); // eg. 2025-07-06
  }

  // 检查两条消息的时间戳是否属于同一天
  static bool isSameDay(DateTime timestamp1, DateTime timestamp2) {
    return formatDate(timestamp1) == formatDate(timestamp2);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDateHeader(DateTime time) {
    final now = DateTime.now();
    if (isSameDay(time, now)) return "今天";
    if (isSameDay(time, now.subtract(const Duration(days: 1)))) return "昨天";
    return DateFormat('yyyy-MM-dd').format(time);
  }

  static DateTime getTimeNow() {
    return  DateTime.now();
  }

  static String formatSmartTime(DateTime time) {
    final now = DateTime.now();

    final diff = now.difference(time);

    if (diff.inMinutes < 1 && isSameDay(time, now)) {
      return '刚刚';
    }

    if (diff.inMinutes < 60 && isSameDay(time, now)) {
      return '${diff.inMinutes} 分钟前';
    }

    if (isSameDay(time, now)) {
      return DateFormat('HH:mm').format(time);
    }

    if (isSameDay(time, now.subtract(const Duration(days: 1)))) {
      return '昨天 ${DateFormat('HH:mm').format(time)}';
    }

    if (isSameDay(time, now.subtract(const Duration(days: 2)))) {
      return '前天 ${DateFormat('HH:mm').format(time)}';
    }

    if (time.year == now.year) {
      return DateFormat('MM月dd日 HH:mm').format(time);
    }

    return DateFormat('yyyy年MM月dd日 HH:mm').format(time);
  }

}
