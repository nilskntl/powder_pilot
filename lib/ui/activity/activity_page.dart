import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../activity/data_provider.dart';
import '../../main.dart';
import '../controller.dart';
import 'info/info.dart';
import 'status/status.dart';

/// The page on which the current activity is displayed.
class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key, required this.customPageController});

  /// The controller for the custom page view and scroll view.
  final CustomController customPageController;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

/// The state for the ActivityPage widget.
class _ActivityPageState extends State<ActivityPage> {
  /// The data provider for the activity.
  late ActivityDataProvider dataProvider =
      Provider.of<ActivityDataProvider>(context);

  @override
  Widget build(BuildContext context) {
    /// Set the static data provider to the data provider of this widget.
    PowderPilot.dataProvider = dataProvider;
    return Column(
      children: [
        Status(
            dataProvider: dataProvider,
            customPageController: widget.customPageController),
        Info(dataProvider: dataProvider),
      ],
    );
  }
}
