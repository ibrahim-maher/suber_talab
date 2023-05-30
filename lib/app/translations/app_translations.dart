import 'package:get/get.dart';

import '../../app/translations/en_US/en_us_translations.dart';
import 'ar_EG/ar_eg_translations.dart';

   class AppTranslation implements Translations{

    Map<String, Map<String, String>> get keys => translations;


    static Map<String, Map<String, String>> translations = {
      'en': enUs,
      'ar': arEg,
    };
  }

