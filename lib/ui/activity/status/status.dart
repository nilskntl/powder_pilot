import 'package:flutter/material.dart';
import 'package:powder_pilot/ui/activity/status/widgets/current_address.dart';
import 'package:powder_pilot/ui/activity/status/widgets/gps_status.dart';
import 'package:powder_pilot/ui/activity/status/widgets/map_overview.dart';
import 'package:powder_pilot/ui/activity/status/status_bar.dart';

import '../../../activity/data_provider.dart';
import '../../../theme.dart';
import '../../controller.dart';

/// The status shows the current status of the activity.
/// It includes the current address, GPS status, map overview and status bar.
class Status extends StatefulWidget {
  const Status(
      {super.key,
      required this.dataProvider,
      required this.customPageController});

  final ActivityDataProvider dataProvider;
  final CustomController customPageController;

  static const double heightBarContainer = 12.0;
  static const double heightBar = 4.0;
  static const double widthBar = 80.0;

  @override
  State<StatefulWidget> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WidgetTheme.container(
            borderRadius: const BorderRadius.all(Radius.circular(0.0)),
            color: ColorTheme.background,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CurrentAddress(
                      dataProvider: widget.dataProvider,
                    ),
                    GpsStatus(
                      dataProvider: widget.dataProvider,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                MapOverview(
                  dataProvider: widget.dataProvider,
                ),
                const SizedBox(height: 8),
                StatusBar(
                  dataProvider: widget.dataProvider,
                  customPageController: widget.customPageController,
                ),
                const SizedBox(height: 8),
              ],
            )),
      ],
    );
  }
}
