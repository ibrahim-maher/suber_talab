import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'DarkThemePreference.dart';

class ThemeController extends GetxController {

  DarkThemePreference darkThemePreference = DarkThemePreference();
  bool _darkTheme = true;

  bool get darkTheme => _darkTheme;
  var isDarkMode = false.obs;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
  }
}

// class DarkThemeProvider with ChangeNotifier {
//   DarkThemePreference darkThemePreference = DarkThemePreference();
//   bool _darkTheme = true;
//
//   bool get darkTheme => _darkTheme;
//
//   set darkTheme(bool value) {
//     _darkTheme = value;
//     darkThemePreference.setDarkTheme(value);
//     notifyListeners();
//   }
// }
