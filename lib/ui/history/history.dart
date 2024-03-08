import 'package:flutter/material.dart';
import 'package:powder_pilot/ui/history/overview/header.dart';

import '../../main.dart';
import '../../string_pool.dart';
import '../../theme/color.dart';
import '../../utils/general_utils.dart';
import 'overview/highlight.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  static void Function() reload = () {};

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    HistoryPage.reload = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: ColorTheme.background,
          padding: const EdgeInsets.all(8.0),
          child: (PowderPilot.pastActivities.numActivities == 0)
              ? Column(
                  children: [
                    HistoryHeader(
                        activities: PowderPilot.pastActivities.activities),
                    const SizedBox(height: 32.0),
                    Center(
                        child: Utils.buildText(text: StringPool.NO_ACTIVITIES)),
                  ],
                )
              : Column(
                  children: [
                    HistoryHeader(
                        activities: PowderPilot.pastActivities.activities),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 336,
                      child: ListView(shrinkWrap: true, children: [
                        Column(
                          children: PowderPilot.pastActivities.activities
                              .map((activity) => Highlight(activity: activity))
                              .toList(),
                        ),
                        const SizedBox(height: 32.0),
                      ]),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
