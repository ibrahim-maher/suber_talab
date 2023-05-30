import 'package:super_talab/app/modules/onboarding_module/onboarding_controller.dart';
import 'package:get/get.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class onboardingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => onboardingController());
  }
}