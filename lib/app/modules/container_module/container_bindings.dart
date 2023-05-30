import 'package:get/get.dart';

import 'container_controller.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class containerBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ContainerController());
  }
}