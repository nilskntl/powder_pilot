import 'package:flutter/material.dart';

import '../../activity/data_provider.dart';
import '../../location.dart';
import '../../theme.dart';
import '../activity/info/info.dart';

class BlinkingGps extends StatefulWidget {
  const BlinkingGps({super.key, required this.dataProvider});

  final ActivityDataProvider dataProvider;

  @override
  State<BlinkingGps> createState() => _BlinkingGpsState();
}

class _BlinkingGpsState extends State<BlinkingGps> {
  bool transparent = false;

  void update() {
    setState(() {
      transparent = !transparent;
    });
  }

  @override
  Widget build(BuildContext context) {
    GpsAccuracy accuracy = widget.dataProvider.gpsAccuracy;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ColorTheme.secondary,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Stack(
            children: [
              Positioned(
                // Position in center
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Icon(
                  accuracy == GpsAccuracy.medium
                      ? LogoTheme.gpsMedium
                      : accuracy == GpsAccuracy.low
                          ? LogoTheme.gpsLow
                          : LogoTheme.gpsHigh,
                  size: Info.iconSize + 8,
                  color: accuracy == GpsAccuracy.medium
                      ? ColorTheme.yellow
                      : accuracy == GpsAccuracy.low
                          ? ColorTheme.red
                          : accuracy == GpsAccuracy.high
                              ? ColorTheme.green
                              : Colors.grey,
                ),
              ),
              AnimatedContainer(
                  duration: const Duration(milliseconds: 2000),
                  width: Info.iconSize + 16,
                  height: Info.iconSize + 16,
                  curve: Curves.easeInOut,
                  decoration: transparent
                      ? BoxDecoration(
                          color: ColorTheme.secondary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8.0),
                        )
                      : BoxDecoration(
                          color: ColorTheme.secondary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                  onEnd: () {
                    update();
                  },
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Icon(
                        LogoTheme.gpsHigh,
                        size: Info.iconSize,
                        color: ColorTheme.grey,
                      ),
                      if (accuracy != GpsAccuracy.none)
                        Icon(
                            accuracy == GpsAccuracy.medium
                                ? LogoTheme.gpsMedium
                                : accuracy == GpsAccuracy.low
                                    ? LogoTheme.gpsLow
                                    : LogoTheme.gpsHigh,
                            size: Info.iconSize,
                            color: accuracy == GpsAccuracy.medium
                                ? ColorTheme.yellow
                                : accuracy == GpsAccuracy.low
                                    ? ColorTheme.red
                                    : ColorTheme.green),
                    ],
                  )),
            ],
          ),
        ))
      ],
    );
  }
}
