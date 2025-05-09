import 'package:get/get.dart';
import '../controllers/photo_capture_controller.dart';

class PhotoCaptureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhotoCaptureController>(
      () => PhotoCaptureController(),
    );
  }
} 