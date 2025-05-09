import 'package:get/get.dart';
import '../controllers/completion_controller.dart';

class CompletionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompletionController>(
      () => CompletionController(),
    );
  }
} 