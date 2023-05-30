import 'package:get/get.dart';
import 'package:super_talab/app/modules/profile_module/profile_controller.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class profileBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => profileController());
  }
}