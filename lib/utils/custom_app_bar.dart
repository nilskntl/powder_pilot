import 'package:flutter/material.dart';

import '../main.dart';
import 'general_utils.dart';

class CustomAppBarDesign {
  static AppBar appBar({required String title}) {
    return AppBar(
        backgroundColor: ColorTheme.contrast,
        foregroundColor: ColorTheme.secondary,
        title: Utils.buildText(
            text: title,
            color: ColorTheme.secondary,
            fontSize: FontTheme.sizeSubHeader - 4));
  }
}