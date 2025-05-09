import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'logger.dart';

/// 错误类型枚举
enum ErrorType {
  network,     // 网络错误
  permission,  // 权限错误
  bluetooth,   // 蓝牙错误
  storage,     // 存储错误
  camera,      // 相机错误
  audio,       // 音频错误
  location,    // 位置错误
  validation,  // 验证错误
  security,    // 安全错误
  general,     // 一般错误
}

/// 应用错误
class AppError {
  final ErrorType type;
  final String message;
  final dynamic exception;
  final StackTrace? stackTrace;
  final String? code;
  
  AppError({
    required this.type,
    required this.message,
    this.exception,
    this.stackTrace,
    this.code,
  });
  
  @override
  String toString() {
    return 'AppError(type: $type, message: $message, code: $code, exception: $exception)';
  }
}

/// 错误处理函数类型
typedef ErrorHandlerFunction = void Function(AppError error);

/// 错误处理器
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();
  
  final Logger _logger = Logger();
  
  /// 全局错误处理回调
  ErrorHandlerFunction? _globalErrorHandler;
  
  /// 特定类型错误处理回调
  final Map<ErrorType, ErrorHandlerFunction> _typeHandlers = {};
  
  /// 设置全局错误处理回调
  void setGlobalErrorHandler(ErrorHandlerFunction handler) {
    _globalErrorHandler = handler;
  }
  
  /// 设置特定类型错误处理回调
  void setTypeErrorHandler(ErrorType type, ErrorHandlerFunction handler) {
    _typeHandlers[type] = handler;
  }
  
  /// 处理错误
  void handleError(AppError error) {
    // 记录错误
    _logError(error);
    
    // 调用对应类型的处理器
    final typeHandler = _typeHandlers[error.type];
    if (typeHandler != null) {
      typeHandler(error);
    }
    
    // 调用全局处理器
    if (_globalErrorHandler != null) {
      _globalErrorHandler!(error);
    }
  }
  
  /// 记录错误
  void _logError(AppError error) {
    _logger.e(
      error.message,
      tag: 'ERROR_${error.type.toString().toUpperCase()}',
      error: error.exception,
      stackTrace: error.stackTrace,
    );
  }
  
  /// 显示错误提示
  void showErrorSnackbar(AppError error) {
    Get.snackbar(
      '错误',
      error.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
  
  /// 创建网络错误
  AppError createNetworkError(String message, {dynamic exception, StackTrace? stackTrace, String? code}) {
    return AppError(
      type: ErrorType.network,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      code: code,
    );
  }
  
  /// 创建权限错误
  AppError createPermissionError(String message, {dynamic exception, StackTrace? stackTrace, String? code}) {
    return AppError(
      type: ErrorType.permission,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      code: code,
    );
  }
  
  /// 创建蓝牙错误
  AppError createBluetoothError(String message, {dynamic exception, StackTrace? stackTrace, String? code}) {
    return AppError(
      type: ErrorType.bluetooth,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      code: code,
    );
  }
  
  /// 创建存储错误
  AppError createStorageError(String message, {dynamic exception, StackTrace? stackTrace, String? code}) {
    return AppError(
      type: ErrorType.storage,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      code: code,
    );
  }
  
  /// 创建相机错误
  AppError createCameraError(String message, {dynamic exception, StackTrace? stackTrace, String? code}) {
    return AppError(
      type: ErrorType.camera,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      code: code,
    );
  }
  
  /// 创建音频错误
  AppError createAudioError(String message, {dynamic exception, StackTrace? stackTrace, String? code}) {
    return AppError(
      type: ErrorType.audio,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      code: code,
    );
  }
  
  /// 创建位置错误
  AppError createLocationError(String message, {dynamic exception, StackTrace? stackTrace, String? code}) {
    return AppError(
      type: ErrorType.location,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      code: code,
    );
  }
  
  /// 创建验证错误
  AppError createValidationError(String message, {dynamic exception, StackTrace? stackTrace, String? code}) {
    return AppError(
      type: ErrorType.validation,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      code: code,
    );
  }
  
  /// 创建安全错误
  AppError createSecurityError(String message, {dynamic exception, StackTrace? stackTrace, String? code}) {
    return AppError(
      type: ErrorType.security,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      code: code,
    );
  }
  
  /// 创建一般错误
  AppError createGeneralError(String message, {dynamic exception, StackTrace? stackTrace, String? code}) {
    return AppError(
      type: ErrorType.general,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      code: code,
    );
  }
  
  /// 创建自动分类的错误
  AppError createError(dynamic exception, String defaultMessage, {StackTrace? stackTrace, String? code}) {
    // 根据异常类型自动分类错误
    String message = defaultMessage;
    ErrorType type = ErrorType.general;
    
    if (exception != null) {
      message = exception.toString();
      
      // 根据异常类型分类
      if (exception.toString().toLowerCase().contains('permission')) {
        type = ErrorType.permission;
      } else if (exception.toString().toLowerCase().contains('network') || 
                 exception.toString().toLowerCase().contains('connection')) {
        type = ErrorType.network;
      } else if (exception.toString().toLowerCase().contains('bluetooth')) {
        type = ErrorType.bluetooth;
      } else if (exception.toString().toLowerCase().contains('storage') ||
                 exception.toString().toLowerCase().contains('file')) {
        type = ErrorType.storage;
      } else if (exception.toString().toLowerCase().contains('camera')) {
        type = ErrorType.camera;
      } else if (exception.toString().toLowerCase().contains('audio') ||
                 exception.toString().toLowerCase().contains('sound')) {
        type = ErrorType.audio;
      } else if (exception.toString().toLowerCase().contains('location') ||
                 exception.toString().toLowerCase().contains('gps')) {
        type = ErrorType.location;
      } else if (exception.toString().toLowerCase().contains('validation') ||
                 exception.toString().toLowerCase().contains('valid')) {
        type = ErrorType.validation;
      } else if (exception.toString().toLowerCase().contains('security') ||
                 exception.toString().toLowerCase().contains('authentication') ||
                 exception.toString().toLowerCase().contains('crypto')) {
        type = ErrorType.security;
      }
    }
    
    return AppError(
      type: type,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      code: code,
    );
  }
}

/// 全局异常捕获
class AppExceptionHandler {
  /// 初始化全局异常捕获
  static void init() {
    // 捕获 Flutter 框架错误
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _handleError(details.exception, details.stack);
    };
    
    // 捕获异步错误
    PlatformDispatcher.instance.onError = (error, stack) {
      _handleError(error, stack);
      return true;
    };
    
    // 捕获区域错误
    runZonedGuarded(() {
      // 应用入口点在这里调用
    }, (error, stack) {
      _handleError(error, stack);
    });
  }
  
  /// 处理错误
  static void _handleError(dynamic error, StackTrace? stack) {
    final errorHandler = ErrorHandler();
    final appError = errorHandler.createError(
      error,
      '应用发生异常',
      stackTrace: stack,
    );
    errorHandler.handleError(appError);
    
    // 仅在调试模式下打印到控制台
    if (kDebugMode) {
      print('捕获到未处理异常: $error');
      if (stack != null) {
        print('堆栈信息: $stack');
      }
    }
  }
} 