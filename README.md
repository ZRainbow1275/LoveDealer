# 记录应用（LoveDealer）

## 项目概述

"记录"（英文名：LoveDealer）是一款用于提供性同意证明的应用程序，旨在为用户提供一个安全、可靠的方式记录双方同意的证据。应用通过多种验证方式（包括录音、人脸识别、拍照等）来确保证据的真实性和完整性。

该应用主要面向现代性意识较为先进，女权意识较为前进的年轻人，设计风格清新好看、同时庄重现代。

## 技术栈

- 开发框架：Flutter
- 开发语言：Dart
- 状态管理：GetX
- UI组件库：Material
- 数据存储：
  - Hive (加密本地存储)
  - Flutter Secure Storage (敏感数据)
- 平台集成：
  - flutter_blue_plus (蓝牙功能)
  - camera (相机功能)
  - flutter_sound (录音功能)
  - google_ml_kit (人脸识别)
  - location (地理位置)
  - permission_handler (权限管理)
  - crypto (加密与哈希)
  - qr_flutter (二维码生成)
  - mobile_scanner (二维码扫描)

## 项目结构

```
lib/
├── main.dart                   # 入口文件
├── app/                        # 应用核心
│   ├── bindings/               # GetX绑定
│   │   └── service_binding.dart  # 服务绑定类
│   ├── controllers/            # GetX控制器
│   ├── data/                   # 数据层
│   │   ├── models/             # 数据模型
│   │   │   ├── personal_info.dart  # 个人信息模型
│   │   │   ├── history_record.dart # 历史记录模型
│   │   │   ├── pairing_info.dart   # 配对信息模型
│   │   │   └── hash_verification.dart # 哈希验证模型
│   │   ├── providers/          # 数据提供者
│   │   └── repositories/       # 数据仓库
│   ├── modules/                # 功能模块
│   │   ├── agreement/          # 协议模块
│   │   ├── history/            # 历史记录模块
│   │   ├── home/               # 主页模块
│   │   ├── pairing/            # 配对模块
│   │   ├── profile/            # 个人信息模块
│   │   ├── record/             # 记录模块
│   │   │   ├── face_recognition/  # 人脸识别子模块
│   │   │   ├── photo_capture/     # 拍照子模块
│   │   │   └── completion/        # 完成子模块
│   │   ├── evidence/          # 证据查看模块
│   │   └── app_info/          # 应用信息模块
│   ├── routes/                # 路由管理
│   ├── services/              # 服务
│   │   ├── bluetooth_service.dart   # 蓝牙服务
│   │   ├── camera_service.dart      # 相机服务
│   │   ├── audio_service.dart       # 录音服务
│   │   ├── face_recognition_service.dart  # 人脸识别服务
│   │   ├── location_service.dart    # 位置服务
│   │   ├── permission_service.dart  # 权限服务
│   │   ├── storage_service.dart     # 存储服务
│   │   ├── hash_service.dart        # 哈希服务
│   │   ├── encryption_service.dart  # 加密服务
│   │   ├── continuous_record_service.dart  # 持续记录服务
│   │   ├── record_service.dart      # 记录管理服务
│   │   └── user_service.dart        # 用户管理服务
│   ├── theme/                 # 主题配置
│   │   ├── color_theme.dart   # 颜色主题
│   │   ├── text_theme.dart    # 文本主题
│   │   ├── theme_service.dart # 主题服务
│   │   └── app_theme.dart     # 应用主题
│   └── utils/                 # 工具类
│       ├── bluetooth_utils.dart     # 蓝牙工具
│       ├── crypto_utils.dart        # 加密与哈希工具
│       ├── date_utils.dart          # 日期时间工具
│       ├── device_utils.dart        # 设备信息工具
│       ├── error_handler.dart       # 错误处理工具
│       ├── logger.dart              # 日志系统
│       ├── notification_utils.dart  # 通知工具
│       └── validators.dart          # 验证工具
└── widgets/                   # 共享组件
    ├── buttons/               # 按钮组件
    ├── forms/                 # 表单组件
    ├── dialogs/               # 对话框组件
    ├── indicators/            # 指示器组件
    └── cards/                 # 卡片组件
```

## 功能特性

### 核心功能

1. **用户协议与隐私政策**
   - 首次使用时强制阅读并接受用户协议和隐私政策
   - 随时可在应用信息中重新查看协议内容

2. **个人信息管理**
   - 个人基本信息的填写与编辑
   - 信息完整度显示
   - 身份信息验证

3. **蓝牙配对**
   - 扫描附近设备
   - 配对码确认机制
   - 设备连接状态监控

4. **记录功能**
   - 同意陈述录入（文字+语音）
   - 人脸识别验证双方身份
   - 场景照片记录
   - 位置信息记录
   - 时间戳记录

5. **持续记录**
   - 后台录音服务
   - 定期拍照
   - 蓝牙连接状态监控

6. **历史记录管理**
   - 记录列表查看
   - 记录详情查看
   - 证据查看（录音、照片、人脸识别结果等）

7. **哈希验证**
   - 记录完整性验证
   - 组件哈希验证
   - 主哈希验证

### 安全特性

1. **数据加密存储**
   - 使用AES加密存储敏感数据
   - 密钥安全管理

2. **哈希验证机制**
   - 多层哈希验证
   - 证据完整性保障

3. **权限管理**
   - 严格的权限请求和检查
   - 权限状态监控

## 当前开发进度

截至目前，项目已完成：

1. **项目初始化与架构设计** [✓已完成]：
   - 完成项目结构搭建
   - 实现GetX状态管理架构
   - 设计基础数据模型
   - 开发基础服务（存储、权限等）

2. **UI组件与页面开发** [✓已完成]：
   - 开发完成基础UI组件（按钮、表单、对话框、指示器、卡片等）
   - 完成主要页面（协议页面、主页、历史记录页面、个人信息页面）
   - 完成记录流程页面（配对页面、同意陈述录入页面、人脸识别页面等）
   - 完成详情与查看页面（详情页面、证据查看页面等）
   - 设计并实现应用主题与样式

3. **核心功能模块开发** [✓已完成]：
   - **用户管理功能**：
     - 实现UserService服务
     - 完成协议签署流程（用户协议、隐私政策）
     - 完成个人信息管理（信息存储、完整度计算、字段验证）
     - 完成用户引导功能（首次使用标记、引导流程）

   - **蓝牙配对功能**：
     - 实现BluetoothService服务
     - 完成设备扫描与发现功能（状态监听、结果更新）
     - 完成配对流程（连接机制、配对码生成与验证）
     - 完成连接状态管理（状态监听、断开处理）

   - **证据收集功能**：
     - 完成相机功能：相机初始化、拍照、照片管理（CameraService）
     - 完成人脸识别：人脸检测、人脸图像提取（FaceRecognitionService）
     - 完成录音功能：录音控制、振幅监听、文件管理（AudioService）
     - 完成位置获取：位置服务、位置监控（LocationService）

   - **数据安全功能**：
     - 实现EncryptionService服务
     - 完成数据加密存储（AES加密、密钥管理）
     - 完成哈希计算与验证（文件哈希、字符串哈希）
     - 完成安全密钥管理（密钥生成、密码保护）

   - **持续记录服务**：
     - 实现ContinuousRecordService服务
     - 完成后台录音功能（持续录音、文件管理）
     - 完成定期拍照功能（定时机制、照片存储）
     - 完成连接监控功能（状态检查、断开处理）
     - 完成会话管理（创建与存储、数据组织）

   - **记录管理功能**：
     - 实现RecordService服务
     - 完成记录创建与存储（信息组织、文件存储）
     - 完成记录检索功能（列表管理、搜索功能）
     - 完成记录验证功能（完整性验证、哈希验证）

## 后续开发计划

1. **近期计划**：
   - 进入第四阶段：测试与优化
   - 编写单元测试（数据模型、工具类、服务类）
   - 进行功能集成测试（配对流程、记录流程、安全功能）
   - 进行性能优化（内存使用、UI渲染、启动时间）

2. **中期计划**：
   - 进入第五阶段：文档与完善
   - 完善代码注释
   - 编写API文档和用户手册
   - 进行最终调整（UI细节、性能调优）

3. **长期计划**：
   - 考虑功能扩展（更多验证方式、云同步）
   - 添加多语言支持
   - 准备应用发布

## 开发指南

### 环境设置

1. 安装Flutter开发环境
2. 克隆项目仓库
3. 安装依赖：`flutter pub get`

### 代码生成

对于Hive模型适配器的生成，需要运行：
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 启动应用

```bash
flutter run
```

## 测试指南

1. **编译运行测试**：
   ```bash
   flutter run --debug
   ```

2. **UI组件验证**：
   - 检查基础UI组件（按钮、表单控件等）在不同设备上的显示效果
   - 验证组件交互是否符合预期

3. **页面功能测试**：
   - 验证已完成页面的功能是否正常
   - 测试页面间导航是否流畅

4. **数据存储测试**：
   - 测试数据保存和读取功能
   - 验证数据模型转换是否正确

## 贡献指南

欢迎提交Issue和Pull Request来帮助改进项目。请确保遵循以下准则：

1. 代码符合项目规范和风格
2. 提交前进行充分的测试
3. 提交信息清晰简洁

## 许可证

本项目采用MIT许可证。详情见[LICENSE](LICENSE)文件。 