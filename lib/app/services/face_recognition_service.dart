import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// 人脸识别服务
/// 
/// 负责人脸检测和人脸识别
class FaceRecognitionService extends GetxService {
  static FaceRecognitionService get to => Get.find<FaceRecognitionService>();
  
  // 人脸检测器
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  
  // 检测到的人脸
  final RxList<Face> faces = <Face>[].obs;
  
  // 人脸图像
  final RxMap<int, String> faceImages = <int, String>{}.obs;
  
  // 人脸识别状态
  final RxBool isProcessing = false.obs;
  
  // 是否检测到人脸
  bool get hasFaces => faces.isNotEmpty;
  
  @override
  void onClose() {
    _faceDetector.close();
    super.onClose();
  }
  
  /// 从图像文件中检测人脸
  Future<List<Face>> detectFacesFromImage(String imagePath) async {
    isProcessing.value = true;
    faces.clear();
    
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final detectedFaces = await _faceDetector.processImage(inputImage);
      faces.value = detectedFaces;
      
      // 从图像中裁剪出人脸
      await _extractFaceImages(imagePath, detectedFaces);
      
      return detectedFaces;
    } catch (e) {
      debugPrint('检测人脸失败: $e');
      return [];
    } finally {
      isProcessing.value = false;
    }
  }
  
  /// 从相机图像中检测人脸
  Future<List<Face>> detectFacesFromCamera(CameraImage cameraImage, CameraDescription camera) async {
    isProcessing.value = true;
    faces.clear();
    
    try {
      // 转换CameraImage为InputImage
      final inputImage = _processImageFromCamera(cameraImage, camera);
      if (inputImage == null) {
        return [];
      }
      
      // 检测人脸
      final detectedFaces = await _faceDetector.processImage(inputImage);
      faces.value = detectedFaces;
      
      // 将相机图像保存为临时文件，以便裁剪人脸
      final tempImagePath = await _saveCameraImageToTemp(cameraImage, camera);
      if (tempImagePath != null) {
        await _extractFaceImages(tempImagePath, detectedFaces);
      }
      
      return detectedFaces;
    } catch (e) {
      debugPrint('从相机检测人脸失败: $e');
      return [];
    } finally {
      isProcessing.value = false;
    }
  }
  
  /// 从图像中裁剪出人脸
  Future<void> _extractFaceImages(String imagePath, List<Face> detectedFaces) async {
    try {
      // 读取图像
      final bytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        return;
      }
      
      // 为每个人脸裁剪图像
      for (final face in detectedFaces) {
        // 获取人脸边界框
        final boundingBox = face.boundingBox;
        
        // 确保裁剪区域在图像范围内
        final left = boundingBox.left.toInt().clamp(0, image.width - 1);
        final top = boundingBox.top.toInt().clamp(0, image.height - 1);
        final width = boundingBox.width.toInt().clamp(1, image.width - left);
        final height = boundingBox.height.toInt().clamp(1, image.height - top);
        
        // 裁剪人脸图像，并增加少量边距
        final padding = (width * 0.1).toInt();
        final paddedLeft = (left - padding).clamp(0, image.width - 1);
        final paddedTop = (top - padding).clamp(0, image.height - 1);
        final paddedWidth = (width + padding * 2).clamp(1, image.width - paddedLeft);
        final paddedHeight = (height + padding * 2).clamp(1, image.height - paddedTop);
        
        final faceImage = img.copyCrop(
          image,
          x: paddedLeft,
          y: paddedTop,
          width: paddedWidth,
          height: paddedHeight,
        );
        
        // 保存裁剪后的人脸图像
        final faceImagePath = await _saveFaceImage(faceImage, face.trackingId ?? 0);
        if (faceImagePath != null) {
          faceImages[face.trackingId ?? 0] = faceImagePath;
        }
      }
    } catch (e) {
      debugPrint('裁剪人脸图像失败: $e');
    }
  }
  
  /// 保存人脸图像
  Future<String?> _saveFaceImage(img.Image faceImage, int faceId) async {
    try {
      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      final faceDir = '${tempDir.path}/faces';
      await Directory(faceDir).create(recursive: true);
      
      // 生成文件名
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'face_${faceId}_$timestamp.jpg';
      final filePath = '$faceDir/$fileName';
      
      // 编码并保存图像
      final jpeg = img.encodeJpg(faceImage, quality: 90);
      await File(filePath).writeAsBytes(jpeg);
      
      return filePath;
    } catch (e) {
      debugPrint('保存人脸图像失败: $e');
      return null;
    }
  }
  
  /// 将相机图像保存为临时文件
  Future<String?> _saveCameraImageToTemp(CameraImage cameraImage, CameraDescription camera) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/temp_camera_image.jpg';
      
      // 将相机图像转换为文件
      final image = await _convertCameraImageToImage(cameraImage, camera);
      if (image == null) {
        return null;
      }
      
      // 保存文件
      final jpeg = img.encodeJpg(image, quality: 90);
      await File(tempPath).writeAsBytes(jpeg);
      
      return tempPath;
    } catch (e) {
      debugPrint('保存相机图像失败: $e');
      return null;
    }
  }
  
  /// 将相机图像转换为图像
  Future<img.Image?> _convertCameraImageToImage(CameraImage cameraImage, CameraDescription camera) async {
    try {
      // 这里的实现会根据相机图像格式不同而不同
      // 以下是一个简化的YUV_420_888格式示例
      
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420ToImage(cameraImage, camera);
      } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888ToImage(cameraImage);
      }
      
      return null;
    } catch (e) {
      debugPrint('转换相机图像失败: $e');
      return null;
    }
  }
  
  /// 将YUV_420_888格式的相机图像转换为图像
  img.Image? _convertYUV420ToImage(CameraImage cameraImage, CameraDescription camera) {
    // 这里是一个简化的转换实现
    // 实际上，完整的YUV到RGB转换相当复杂
    
    // 在实际应用中，建议使用更完整的转换库或方法
    // 例如camera插件的示例中提供的转换方法
    
    // 由于转换复杂度较高，这里返回null
    // 实际开发中应使用专门的图像处理库实现此功能
    return null;
  }
  
  /// 将BGRA8888格式的相机图像转换为图像
  img.Image? _convertBGRA8888ToImage(CameraImage cameraImage) {
    try {
      final planes = cameraImage.planes;
      if (planes.isEmpty) return null;
      
      final width = cameraImage.width;
      final height = cameraImage.height;
      
      // 创建图像
      final image = img.Image(width: width, height: height);
      
      // 填充像素数据
      final bytes = planes[0].bytes;
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixelIndex = (y * width + x) * 4;
          if (pixelIndex + 3 < bytes.length) {
            // BGRA -> RGBA
            final b = bytes[pixelIndex];
            final g = bytes[pixelIndex + 1];
            final r = bytes[pixelIndex + 2];
            final a = bytes[pixelIndex + 3];
            
            // 使用正确的颜色设置方法
            image.setPixelRgba(x, y, r, g, b, a);
          }
        }
      }
      
      return image;
    } catch (e) {
      debugPrint('转换BGRA图像失败: $e');
      return null;
    }
  }
  
  /// 处理相机图像
  InputImage? _processImageFromCamera(CameraImage cameraImage, CameraDescription camera) {
    try {
      // 获取图像旋转信息
      final rotation = _getImageRotation(camera.sensorOrientation);
      
      // 构建InputImage
      if (Platform.isAndroid) {
        // Android使用nv21格式
        if (cameraImage.format.group != ImageFormatGroup.nv21) {
          debugPrint('不支持的图像格式: ${cameraImage.format.group}，Android仅支持nv21格式');
          return null;
        }
        
        final plane = cameraImage.planes.first;
        final imageRotation = InputImageRotationValue.fromRawValue(rotation) ?? 
                             InputImageRotation.rotation0deg;
        
        return InputImage.fromBytes(
          bytes: plane.bytes,
          metadata: InputImageMetadata(
            size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
            rotation: imageRotation,
            format: InputImageFormat.nv21,
            bytesPerRow: plane.bytesPerRow,
          ),
        );
      } else if (Platform.isIOS) {
        // iOS使用bgra8888格式
        if (cameraImage.format.group != ImageFormatGroup.bgra8888) {
          debugPrint('不支持的图像格式: ${cameraImage.format.group}，iOS仅支持bgra8888格式');
          return null;
        }
        
        final plane = cameraImage.planes.first;
        final imageRotation = InputImageRotationValue.fromRawValue(rotation) ?? 
                             InputImageRotation.rotation0deg;
        
        return InputImage.fromBytes(
          bytes: plane.bytes,
          metadata: InputImageMetadata(
            size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
            rotation: imageRotation,
            format: InputImageFormat.bgra8888,
            bytesPerRow: plane.bytesPerRow,
          ),
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('处理相机图像失败: $e');
      return null;
    }
  }
  
  /// 获取图像旋转信息
  int _getImageRotation(int sensorOrientation) {
    // 使用固定角度简化实现，避免设备方向处理的复杂性
    if (Platform.isAndroid) {
      // 在Android上，根据相机方向和传感器方向计算旋转角度
      int rotationCompensation = 0;
      if (sensorOrientation == 90) {
        rotationCompensation = 90;
      } else if (sensorOrientation == 180) {
        rotationCompensation = 180;
      } else if (sensorOrientation == 270) {
        rotationCompensation = 270;
      }
      return rotationCompensation;
    } else {
      // 在iOS上，直接使用传感器方向
      return sensorOrientation;
    }
  }
  
  /// 清理临时文件
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final faceDir = Directory('${tempDir.path}/faces');
      
      if (await faceDir.exists()) {
        await faceDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('清理临时文件失败: $e');
    }
  }
  
  /// 获取检测到的人脸数量
  int get faceCount => faces.length;
} 