import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../utils/logger.dart';

/// 用户数据模型
class User {
  final String? id;
  final String? username;
  final String? email;
  final String? avatar;
  
  User({
    this.id,
    this.username,
    this.email,
    this.avatar,
  });
}

/// 认证服务，负责用户认证相关功能
class AuthService extends GetxService {
  /// 获取AuthService实例
  static AuthService get to => Get.find<AuthService>();
  
  final Logger _logger = Logger();
  
  // 用户状态
  final Rx<User?> _currentUser = Rx<User?>(null);
  
  /// 获取当前用户
  User? get user => _currentUser.value;
  
  /// 初始化服务
  Future<AuthService> init() async {
    _logger.i('AuthService 初始化');
    
    // 加载当前用户信息（示例数据）
    _currentUser.value = User(
      id: '1',
      username: '测试用户',
      email: 'test@example.com',
      avatar: '',
    );
    
    return this;
  }
  
  /// 获取当前用户
  Future<User?> getCurrentUser() async {
    // 实际实现中应该从本地存储或接口获取当前用户信息
    return _currentUser.value;
  }
  
  /// 登录
  Future<User?> login(String username, String password) async {
    try {
      _logger.i('用户尝试登录: $username');
      
      // 实际实现中应该调用登录接口
      // 这里仅作为示例实现
      _currentUser.value = User(
        id: '1',
        username: username,
        email: '$username@example.com',
        avatar: '',
      );
      
      return _currentUser.value;
    } catch (e) {
      _logger.e('登录失败', error: e);
      return null;
    }
  }
  
  /// 注册
  Future<User?> register(String username, String email, String password) async {
    try {
      _logger.i('用户尝试注册: $username, $email');
      
      // 实际实现中应该调用注册接口
      // 这里仅作为示例实现
      _currentUser.value = User(
        id: '1',
        username: username,
        email: email,
        avatar: '',
      );
      
      return _currentUser.value;
    } catch (e) {
      _logger.e('注册失败', error: e);
      return null;
    }
  }
  
  /// 退出登录
  Future<void> logout() async {
    try {
      _logger.i('用户退出登录');
      
      // 实际实现中应该清除本地存储的用户信息
      _currentUser.value = null;
    } catch (e) {
      _logger.e('退出登录失败', error: e);
      rethrow;
    }
  }
  
  /// 更新用户信息
  Future<User?> updateUserInfo({
    String? username,
    String? email,
    String? avatar,
  }) async {
    try {
      if (_currentUser.value == null) {
        throw Exception('未登录');
      }
      
      // 实际实现中应该调用更新接口
      _currentUser.value = User(
        id: _currentUser.value!.id,
        username: username ?? _currentUser.value!.username,
        email: email ?? _currentUser.value!.email,
        avatar: avatar ?? _currentUser.value!.avatar,
      );
      
      return _currentUser.value;
    } catch (e) {
      _logger.e('更新用户信息失败', error: e);
      return null;
    }
  }
} 