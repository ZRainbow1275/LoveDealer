import 'package:get/get.dart';
import '../controllers/pairing_controller.dart';

class PairingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PairingController>(
      () => PairingController(),
    );
  }
} 