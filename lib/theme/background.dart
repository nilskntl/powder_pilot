import 'package:flutter/foundation.dart';
import 'package:powder_pilot/main.dart';
import 'package:powder_pilot/utils/shared_preferences.dart';

/// This file contains the list of background images used in the app.
class BackgroundTheme {
  /// Theme key
  static const String key = PowderPilot.backgroundKey;

  /// The current background image
  static String currentBackgroundKey = backgrounds[0][0];
  static String currentBackgroundAsset = backgrounds[0][1];

  /// Load the current background image from SharedPreferences
  static void loadBackground() async {
    String fromSharedPref = await SharedPref.readString(key);
    if (fromSharedPref.isNotEmpty && fromSharedPref != '') {
      currentBackgroundKey = fromSharedPref;
      currentBackgroundAsset = backgrounds
          .firstWhere((element) => element[0] == currentBackgroundKey)[1];
    }
  }

  /// Change the background image
  ///
  /// @param background The background image to switch to
  static void changeBackground(String background) {
    if (kDebugMode) {
      print('Changing background to $background');
    }
    SharedPref.saveString(key, background);
    currentBackgroundKey = background;
    currentBackgroundAsset = backgrounds
        .firstWhere((element) => element[0] == currentBackgroundKey)[1];
  }

  /// List of background images
  static const List<List<String>> backgrounds = [
    ['Alpine', 'assets/images/backgrounds/Alpine.jpg'],
    ['Chalet', 'assets/images/backgrounds/Chalet.jpg'],
    ['Snowy', 'assets/images/backgrounds/Snowy.jpg'],
    ['Village', 'assets/images/backgrounds/Village.jpg'],
    ['Exotic', 'assets/images/backgrounds/Exotic.jpg'],
    ['Ice', 'assets/images/backgrounds/Ice.jpg'],
  ];
}
