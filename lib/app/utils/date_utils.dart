import 'package:intl/intl.dart';

/// 日期时间工具类
class DateTimeUtils {
  /// 默认日期格式
  static const String defaultDateFormat = 'yyyy-MM-dd';
  
  /// 默认日期时间格式
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  /// 简短日期时间格式
  static const String shortDateTimeFormat = 'MM-dd HH:mm';
  
  /// 仅时间格式
  static const String timeOnlyFormat = 'HH:mm:ss';
  
  /// 仅小时分钟格式
  static const String hourMinuteFormat = 'HH:mm';
  
  /// 友好的日期格式
  static const String friendlyDateFormat = 'MM月dd日';
  
  /// 友好的日期时间格式
  static const String friendlyDateTimeFormat = 'MM月dd日 HH:mm';
  
  /// 格式化日期时间
  static String formatDateTime(DateTime dateTime, {String format = defaultDateTimeFormat}) {
    return DateFormat(format).format(dateTime);
  }
  
  /// 格式化日期
  static String formatDate(DateTime dateTime, {String format = defaultDateFormat}) {
    return DateFormat(format).format(dateTime);
  }
  
  /// 格式化时间
  static String formatTime(DateTime dateTime, {String format = timeOnlyFormat}) {
    return DateFormat(format).format(dateTime);
  }
  
  /// 解析字符串为日期时间
  static DateTime? parseDateTime(String dateTimeString, {String format = defaultDateTimeFormat}) {
    try {
      return DateFormat(format).parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }
  
  /// 解析字符串为日期
  static DateTime? parseDate(String dateString, {String format = defaultDateFormat}) {
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// 获取当前日期时间
  static DateTime now() {
    return DateTime.now();
  }
  
  /// 获取当天开始时间
  static DateTime startOfDay([DateTime? dateTime]) {
    final date = dateTime ?? DateTime.now();
    return DateTime(date.year, date.month, date.day);
  }
  
  /// 获取当天结束时间
  static DateTime endOfDay([DateTime? dateTime]) {
    final date = dateTime ?? DateTime.now();
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
  /// 获取本周开始时间（星期一）
  static DateTime startOfWeek([DateTime? dateTime]) {
    final date = dateTime ?? DateTime.now();
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - weekday + 1);
  }
  
  /// 获取本周结束时间（星期日）
  static DateTime endOfWeek([DateTime? dateTime]) {
    final date = dateTime ?? DateTime.now();
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day + (7 - weekday), 23, 59, 59, 999);
  }
  
  /// 获取本月开始时间
  static DateTime startOfMonth([DateTime? dateTime]) {
    final date = dateTime ?? DateTime.now();
    return DateTime(date.year, date.month, 1);
  }
  
  /// 获取本月结束时间
  static DateTime endOfMonth([DateTime? dateTime]) {
    final date = dateTime ?? DateTime.now();
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }
  
  /// 获取本年开始时间
  static DateTime startOfYear([DateTime? dateTime]) {
    final date = dateTime ?? DateTime.now();
    return DateTime(date.year, 1, 1);
  }
  
  /// 获取本年结束时间
  static DateTime endOfYear([DateTime? dateTime]) {
    final date = dateTime ?? DateTime.now();
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }
  
  /// 添加天数
  static DateTime addDays(DateTime dateTime, int days) {
    return dateTime.add(Duration(days: days));
  }
  
  /// 添加小时
  static DateTime addHours(DateTime dateTime, int hours) {
    return dateTime.add(Duration(hours: hours));
  }
  
  /// 添加分钟
  static DateTime addMinutes(DateTime dateTime, int minutes) {
    return dateTime.add(Duration(minutes: minutes));
  }
  
  /// 添加秒数
  static DateTime addSeconds(DateTime dateTime, int seconds) {
    return dateTime.add(Duration(seconds: seconds));
  }
  
  /// 减去天数
  static DateTime subtractDays(DateTime dateTime, int days) {
    return dateTime.subtract(Duration(days: days));
  }
  
  /// 减去小时
  static DateTime subtractHours(DateTime dateTime, int hours) {
    return dateTime.subtract(Duration(hours: hours));
  }
  
  /// 减去分钟
  static DateTime subtractMinutes(DateTime dateTime, int minutes) {
    return dateTime.subtract(Duration(minutes: minutes));
  }
  
  /// 减去秒数
  static DateTime subtractSeconds(DateTime dateTime, int seconds) {
    return dateTime.subtract(Duration(seconds: seconds));
  }
  
  /// 计算两个日期之间的天数差
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
  
  /// 计算两个日期之间的小时差
  static int hoursBetween(DateTime from, DateTime to) {
    return to.difference(from).inHours;
  }
  
  /// 计算两个日期之间的分钟差
  static int minutesBetween(DateTime from, DateTime to) {
    return to.difference(from).inMinutes;
  }
  
  /// 计算两个日期之间的秒数差
  static int secondsBetween(DateTime from, DateTime to) {
    return to.difference(from).inSeconds;
  }
  
  /// 检查两个日期是否是同一天
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
  
  /// 检查两个日期是否是同一周
  static bool isSameWeek(DateTime date1, DateTime date2) {
    final startOfWeek1 = startOfWeek(date1);
    final startOfWeek2 = startOfWeek(date2);
    return isSameDay(startOfWeek1, startOfWeek2);
  }
  
  /// 检查两个日期是否是同一月
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }
  
  /// 检查两个日期是否是同一年
  static bool isSameYear(DateTime date1, DateTime date2) {
    return date1.year == date2.year;
  }
  
  /// 获取相对时间描述（例如：刚刚、x分钟前、x小时前、昨天、x天前）
  static String getRelativeTimeDescription(DateTime dateTime, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final difference = currentTime.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (isSameDay(currentTime, addDays(dateTime, 1))) {
      return '昨天 ${formatTime(dateTime, format: hourMinuteFormat)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (isSameYear(currentTime, dateTime)) {
      return formatDateTime(dateTime, format: friendlyDateTimeFormat);
    } else {
      return formatDateTime(dateTime, format: defaultDateTimeFormat);
    }
  }
  
  /// 获取中文星期几
  static String getChineseWeekday(DateTime dateTime) {
    final List<String> weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '星期${weekdays[dateTime.weekday - 1]}';
  }
  
  /// 获取农历日期（简单实现，不考虑闰月等复杂情况）
  static String getLunarDate(DateTime dateTime) {
    // 注意：这只是一个简单的占位实现
    // 实际应用中，建议使用专门的农历日期库
    return '农历日期功能待实现';
  }
} 