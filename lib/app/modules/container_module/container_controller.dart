import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/User.dart';
import '../../data/repository/localDatabase.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../utils/constants.dart';
import 'container_page.dart';

class ContainerController extends GetxController {
  final fireStoreUtils = FireStoreUtils();
  final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  late CartDatabase cartDatabase;
  late User user;
  late String appBarTitle;
  late Widget currentWidget;
 // late DrawerSelection drawerSelection;

  final cartCount = 0.obs;
  final isWalletEnable = false.obs;

  @override
  void onInit() {
    super.onInit();
    setCurrency();
    // Add your additional initialization code here
  }

  setCurrency() async {
    await FireStoreUtils().getCurrency().then((value) {
      for (var element in value) {
        if (element.isactive = true) {
          symbol = element.symbol;
          isRight = element.symbolatright;
          currName = element.code;
          decimal = element.decimal;
          currencyData = element;
        }
      }
    });

    await FireStoreUtils.getReferralAmount();
  }

}