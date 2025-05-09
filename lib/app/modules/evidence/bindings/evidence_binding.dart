import 'package:get/get.dart';
import '../controllers/evidence_controller.dart';

class EvidenceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EvidenceController>(
      () => EvidenceController(),
    );
  }
} 