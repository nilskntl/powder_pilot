import 'package:flutter/cupertino.dart';

import '../../../../activity/data_provider.dart';
import '../../../../location.dart';
import '../../../../theme.dart';

/// The GPS status shows the current GPS status.
class GpsStatus extends StatefulWidget {
  const GpsStatus({super.key, required this.dataProvider});

  final ActivityDataProvider dataProvider;

  final double size = 32.0;

  @override
  State<GpsStatus> createState() => _GpsStatusState();
}

class _GpsStatusState extends State<GpsStatus> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(
          LogoTheme.gpsHigh,
          size: widget.size,
          color: ColorTheme.grey,
        ),
        if (widget.dataProvider.gpsAccuracy != GpsAccuracy.none)
          Icon(
              widget.dataProvider.gpsAccuracy == GpsAccuracy.medium
                  ? LogoTheme.gpsMedium
                  : widget.dataProvider.gpsAccuracy == GpsAccuracy.low
                      ? LogoTheme.gpsLow
                      : LogoTheme.gpsHigh,
              size: widget.size,
              color: widget.dataProvider.gpsAccuracy == GpsAccuracy.medium
                  ? ColorTheme.yellow
                  : widget.dataProvider.gpsAccuracy == GpsAccuracy.low
                      ? ColorTheme.red
                      : ColorTheme.green),
      ],
    );
  }
}
