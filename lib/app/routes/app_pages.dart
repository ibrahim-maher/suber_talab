import '../../app/modules/container_module/container_page.dart';
import '../../app/modules/container_module/container_bindings.dart';

import '../../app/modules/profile_module/profile_page.dart';
import '../../app/modules/profile_module/profile_bindings.dart';
import '../../app/modules/onboarding_module/onboarding_page.dart';
import '../../app/modules/onboarding_module/onboarding_bindings.dart';
import '../../app/modules/auth_module/auth_page.dart';
import '../../app/modules/auth_module/auth_bindings.dart';

import '../../app/modules/home_module/home_bindings.dart';
import '../../app/modules/home_module/home_page.dart';
import 'package:get/get.dart';

import '../modules/profile_module/account_details_screen.dart';
part './app_routes.dart';


abstract class AppPages {

  static final pages = [
    GetPage(
      name: Routes.HOME,
      page: () => homePage(user: null,),
      binding: homeBinding(),
    ),

    GetPage(
      name: Routes.AUTH,
      page: () => AuthPage(),
      binding: authBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => onboardingPage(),
      binding: onboardingBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => profilePage(),
      binding: profileBinding(),
    ),
    GetPage(
      name: Routes.ACCOUNT_DETAIL_PAGE,
      page: () => AccountDetailsPage(),
      binding: profileBinding(),
    ),


  ];
}
