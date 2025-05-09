import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  // 底部导航切换
  void changePage(int index) {
    selectedIndex.value = index;
  }

  // 跳转到配对页面
  void goToPairing() {
    Get.toNamed(Routes.PAIRING);
  }

  // 跳转到历史记录
  void goToHistory() {
    Get.toNamed(Routes.HISTORY);
  }

  // 跳转到个人资料
  void goToProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  // 跳转到应用信息
  void goToAppInfo() {
    Get.toNamed(Routes.APP_INFO);
  }
} 