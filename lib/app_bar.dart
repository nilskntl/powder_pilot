import 'package:flutter/material.dart';
import 'package:ski_tracker/utils/general_utils.dart';

import 'main.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  static const barHeight = 64.0;
  static const itemsSize = 40.0;

  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: getStatusBarHeight(context),
        ),
        Container(
          height: barHeight,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/images/icon_256.png",
                    width: itemsSize,
                    height: itemsSize,
                  ),
                  const SizedBox(width: itemsSize),
                ],
              ),
              Utils.buildText(
                text: 'Ski Tracker',
                fontSize: FontTheme.size,
                fontWeight: FontWeight.bold,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: const SizedBox(
                      width: itemsSize,
                      height: itemsSize,
                      child: Icon(
                        Icons.person_rounded,
                        color: ColorTheme.contrastColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const SizedBox(
                      width: itemsSize,
                      height: itemsSize,
                      child: Icon(
                        Icons.settings_rounded,
                        color: ColorTheme.contrastColor,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
