import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/bindings/service_binding.dart';
import 'app/services/storage_service.dart';
import 'app/services/permission_service.dart';
import 'app/controllers/app_controller.dart';
import 'app/utils/logger.dart';
import 'app/utils/error_handler.dart';
import 'app/utils/device_utils.dart';
import 'app/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // 初始化日志系统
  final logger = Logger();
  logger.configure(
    level: LogLevel.debug,
    writeToFile: true,
    retentionDays: 7,
  );
  
  // 初始化全局异常捕获
  AppExceptionHandler.init();
  
  // 设置错误处理器
  final errorHandler = ErrorHandler();
  errorHandler.setGlobalErrorHandler((error) {
    logger.e('全局错误: ${error.message}', 
      tag: 'GLOBAL', 
      error: error.exception, 
      stackTrace: error.stackTrace
    );
    
    // 显示错误提示
    errorHandler.showErrorSnackbar(error);
  });
  
  // 初始化设备信息
  final deviceUtils = DeviceUtils();
  await deviceUtils.init();
  logger.i('设备信息: ${deviceUtils.getDeviceBrand()} ${deviceUtils.getDeviceModel()}, '
          '系统: ${deviceUtils.getDeviceOS()} ${deviceUtils.getOSVersion()}');
  
  try {
    // 初始化Hive
    await Hive.initFlutter();
    
    // 初始化基础服务
    await Get.putAsync(() => StorageService().init());
    await Get.putAsync(() => PermissionService().init());
    
    // 注入全局控制器
    Get.put(AppController(), permanent: true);
    
    await GetStorage.init();
    
    logger.i('应用初始化完成');
  } catch (e, stackTrace) {
    final appError = errorHandler.createError(
      e, 
      '应用初始化失败', 
      stackTrace: stackTrace
    );
    errorHandler.handleError(appError);
  }
  
  // 包装runApp以捕获框架异常
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    final appError = errorHandler.createError(
      error, 
      '应用崩溃', 
      stackTrace: stackTrace
    );
    errorHandler.handleError(appError);
  });
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final ThemeService _themeService = ThemeService();
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '记录',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      themeMode: _themeService.theme,
      theme: _themeService.lightTheme,
      darkTheme: _themeService.darkTheme,
      defaultTransition: Transition.fadeIn,
      initialBinding: ServiceBinding(),
      locale: const Locale('zh', 'CN'),
      fallbackLocale: const Locale('en', 'US'),
      enableLog: true,
      logWriterCallback: (String text, {bool isError = false}) {
        final logger = Logger();
        if (isError) {
          logger.e('GetX: $text');
        } else {
          logger.d('GetX: $text');
        }
      },
    );
  }
} 