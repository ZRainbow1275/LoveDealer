import 'package:get/get.dart';

/// 表单验证工具类，提供常用的表单验证函数
class Validators {
  Validators._();

  /// 验证是否非空
  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return '此字段不能为空';
    }
    return null;
  }

  /// 验证姓名
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入姓名';
    }
    if (value.length < 2) {
      return '姓名至少需要2个字符';
    }
    return null;
  }

  /// 验证身份证号码
  static String? validateIdNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入身份证号码';
    }
    
    // 正则表达式：18位身份证号码
    final RegExp idCardReg = RegExp(r'^\d{17}[\dXx]$');
    
    if (!idCardReg.hasMatch(value)) {
      return '身份证号码格式不正确';
    }
    
    // 这里可以加入更复杂的身份证验证逻辑，比如校验码计算等
    
    return null;
  }

  /// 验证手机号码
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号码';
    }
    
    // 正则表达式：11位手机号码，以1开头
    final RegExp phoneReg = RegExp(r'^1\d{10}$');
    
    if (!phoneReg.hasMatch(value)) {
      return '手机号码格式不正确';
    }
    
    return null;
  }

  /// 验证邮箱
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    
    if (!GetUtils.isEmail(value)) {
      return '邮箱格式不正确';
    }
    
    return null;
  }

  /// 验证密码
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    
    if (value.length < 6) {
      return '密码至少需要6个字符';
    }
    
    // 可选：要求包含数字、大小写字母等
    final RegExp hasNumber = RegExp(r'[0-9]');
    final RegExp hasUppercase = RegExp(r'[A-Z]');
    final RegExp hasLowercase = RegExp(r'[a-z]');
    
    if (!hasNumber.hasMatch(value) || 
        !hasUppercase.hasMatch(value) || 
        !hasLowercase.hasMatch(value)) {
      return '密码需要包含数字、大写字母和小写字母';
    }
    
    return null;
  }

  /// 验证两次密码是否一致
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '请再次输入密码';
    }
    
    if (value != password) {
      return '两次输入的密码不一致';
    }
    
    return null;
  }

  /// 验证输入长度范围
  static String? validateLength(String? value, int min, int max) {
    if (value == null || value.isEmpty) {
      return '此字段不能为空';
    }
    
    if (value.length < min) {
      return '长度至少需要$min个字符';
    }
    
    if (value.length > max) {
      return '长度不能超过$max个字符';
    }
    
    return null;
  }

  /// 验证数字范围
  static String? validateNumberRange(String? value, double min, double max) {
    if (value == null || value.isEmpty) {
      return '此字段不能为空';
    }
    
    final double? number = double.tryParse(value);
    if (number == null) {
      return '请输入有效的数字';
    }
    
    if (number < min) {
      return '数值不能小于$min';
    }
    
    if (number > max) {
      return '数值不能大于$max';
    }
    
    return null;
  }

  /// 验证URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入网址';
    }
    
    if (!GetUtils.isURL(value)) {
      return '网址格式不正确';
    }
    
    return null;
  }

  /// 验证配对码
  static String? validatePairingCode(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入配对码';
    }
    
    if (value.length != 6 || !GetUtils.isNumericOnly(value)) {
      return '配对码应为6位数字';
    }
    
    return null;
  }

  /// 验证同意陈述文本
  static String? validateConsentStatement(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入同意陈述';
    }
    
    if (value.length < 10) {
      return '同意陈述过短，请详细描述';
    }
    
    return null;
  }
} 