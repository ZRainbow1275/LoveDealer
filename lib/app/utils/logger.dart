import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// 日志级别枚举
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  critical,
}

/// 日志系统
class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  /// 日志级别
  LogLevel _currentLevel = LogLevel.debug;
  
  /// 是否将日志写入文件
  bool _writeToFile = true;
  
  /// 日志文件保留天数
  int _logRetentionDays = 7;
  
  /// 日志文件名格式
  final DateFormat _fileNameFormat = DateFormat('yyyyMMdd');
  
  /// 日志时间格式
  final DateFormat _logTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  
  /// 日志级别标签
  final Map<LogLevel, String> _levelTags = {
    LogLevel.verbose: 'V',
    LogLevel.debug: 'D',
    LogLevel.info: 'I',
    LogLevel.warning: 'W',
    LogLevel.error: 'E',
    LogLevel.critical: 'C',
  };
  
  /// 日志级别颜色（仅控制台显示）
  final Map<LogLevel, String> _levelColors = {
    LogLevel.verbose: '\x1B[37m', // 白色
    LogLevel.debug: '\x1B[36m',   // 青色
    LogLevel.info: '\x1B[32m',    // 绿色
    LogLevel.warning: '\x1B[33m', // 黄色
    LogLevel.error: '\x1B[31m',   // 红色
    LogLevel.critical: '\x1B[35m',// 紫色
  };
  
  final String _resetColor = '\x1B[0m';
  
  /// 配置日志系统
  void configure({
    LogLevel? level,
    bool? writeToFile,
    int? retentionDays,
  }) {
    _currentLevel = level ?? _currentLevel;
    _writeToFile = writeToFile ?? _writeToFile;
    _logRetentionDays = retentionDays ?? _logRetentionDays;
    
    if (_writeToFile) {
      _cleanupOldLogs();
    }
  }
  
  /// 记录详细日志
  void v(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.verbose, message, tag, error, stackTrace);
  }
  
  /// 记录调试日志
  void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag, error, stackTrace);
  }
  
  /// 记录信息日志
  void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag, error, stackTrace);
  }
  
  /// 记录警告日志
  void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag, error, stackTrace);
  }
  
  /// 记录错误日志
  void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag, error, stackTrace);
  }
  
  /// 记录严重错误日志
  void c(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message, tag, error, stackTrace);
  }
  
  /// 内部日志记录方法
  void _log(LogLevel level, String message, String? tag, Object? error, StackTrace? stackTrace) {
    if (level.index < _currentLevel.index) return;
    
    final time = _logTimeFormat.format(DateTime.now());
    final levelTag = _levelTags[level] ?? '?';
    final tagStr = tag != null ? '[$tag]' : '';
    
    String logMessage = '$time $levelTag $tagStr $message';
    if (error != null) {
      logMessage += '\nError: $error';
    }
    if (stackTrace != null) {
      logMessage += '\nStackTrace: $stackTrace';
    }
    
    // 控制台输出（带颜色）
    if (kDebugMode) {
      final colorCode = _levelColors[level] ?? '';
      debugPrint('$colorCode$logMessage$_resetColor');
    }
    
    // 写入文件
    if (_writeToFile) {
      _writeLogToFile(logMessage);
    }
  }
  
  /// 写入日志文件
  Future<void> _writeLogToFile(String logMessage) async {
    try {
      final directory = await _getLogDirectory();
      final fileName = '${_fileNameFormat.format(DateTime.now())}.log';
      final file = File('${directory.path}/$fileName');
      
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      
      await file.writeAsString('$logMessage\n', mode: FileMode.append);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('写入日志文件失败: $e');
      }
    }
  }
  
  /// 获取日志目录
  Future<Directory> _getLogDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDocDir.path}/logs');
    
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    
    return logDir;
  }
  
  /// 清理过期日志文件
  Future<void> _cleanupOldLogs() async {
    try {
      final logDir = await _getLogDirectory();
      final now = DateTime.now();
      
      final files = await logDir.list().toList();
      for (var entity in files) {
        if (entity is File && entity.path.endsWith('.log')) {
          final fileName = entity.uri.pathSegments.last;
          try {
            final dateString = fileName.substring(0, 8); // 提取 YYYYMMDD
            final fileDate = _fileNameFormat.parse(dateString);
            final difference = now.difference(fileDate).inDays;
            
            if (difference > _logRetentionDays) {
              await entity.delete();
              if (kDebugMode) {
                debugPrint('已删除过期日志文件: ${entity.path}');
              }
            }
          } catch (e) {
            // 文件名格式不符，跳过处理
            continue;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('清理过期日志失败: $e');
      }
    }
  }
  
  /// 获取所有日志文件
  Future<List<File>> getLogFiles() async {
    try {
      final logDir = await _getLogDirectory();
      final files = await logDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.log'))
        .map((entity) => entity as File)
        .toList();
      
      // 按日期排序，最新的在前
      files.sort((a, b) => b.path.compareTo(a.path));
      return files;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('获取日志文件列表失败: $e');
      }
      return [];
    }
  }
} 