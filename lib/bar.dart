import 'package:flutter/material.dart';
import 'package:ski_tracker/utils.dart';

import 'main.dart';

class Bar extends StatelessWidget {
  const Bar({super.key});

  static const barHeight = 64.0;
  static const itemsSize = 40.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: barHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          Image.asset(
            "assets/images/icon_256.png",
            width: itemsSize,
            height: itemsSize,
          ),
          const SizedBox(width: 8),
          Utils.buildText(
            text: 'Ski Tracker',
            color: ColorTheme.contrastColor,
            fontSize: 24,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {

            },
            child: Container(
              width: itemsSize,
              height: itemsSize,
              decoration: BoxDecoration(
                color: ColorTheme.contrastColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: ColorTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {

            },
            child: Container(
              width: itemsSize,
              height: itemsSize,
              decoration: BoxDecoration(
                color: ColorTheme.contrastColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: ColorTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
