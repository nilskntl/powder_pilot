import 'package:flutter/material.dart';
import 'package:powder_pilot/ui/statistics/activities/number_activities.dart';
import 'package:provider/provider.dart';

import '../../activity/data_provider.dart';
import '../../main.dart';
import '../controller.dart';

/// The page on which the statistics are displayed.
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  static void Function() reload = () {};

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

/// The state for the StatisticsPage widget.
class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    StatisticsPage.reload = () {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NumberActivities(),
      ],
    );
  }
}
