import 'package:flutter/material.dart';
import 'package:powder_pilot/ui/history/overview/header.dart';

import '../../../activity/database.dart';
import '../../../string_pool.dart';
import '../../../theme.dart';
import '../../../utils/general_utils.dart';
import 'highlight.dart';

class History extends StatefulWidget {
  const History({super.key});

  static void Function() reload = () {};

  @override
  State<History> createState() => HistoryState();
}

class HistoryState extends State<History> {
  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    History.reload = () {
     if(mounted) {
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
          child: FutureBuilder<List<ActivityDatabase>>(
            /// Assuming your activities() method returns a Future<List<ActivityDatabase>>
            future: ActivityDatabaseHelper.activities(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                /// While data is being fetched, display a loading indicator
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                /// If there's an error, display an error message
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                /// If data is successfully fetched, build the Column
                List<ActivityDatabase>? activities = snapshot.data;

                if (activities == null || activities.isEmpty) {
                  return Column(
                    children: [
                      HistoryHeader(activities: activities),
                      const SizedBox(height: 32.0),
                      Center(
                          child:
                              Utils.buildText(text: StringPool.NO_ACTIVITIES)),
                    ],
                  );
                } else {
                  /// Sort activities based on startTime in descending order
                  activities.sort((a, b) => b.startTime.compareTo(a.startTime));
                  return Column(
                    children: [
                      HistoryHeader(activities: activities),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 336,
                        child: ListView(shrinkWrap: true, children: [
                          Column(
                            children: activities
                                .map(
                                    (activity) => Highlight(activity: activity))
                                .toList(),
                          ),
                          const SizedBox(height: 32.0),
                        ]),
                      ),
                    ],
                  );
                }
              }
            },
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
