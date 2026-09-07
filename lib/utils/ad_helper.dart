import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    return '';
  }
}
