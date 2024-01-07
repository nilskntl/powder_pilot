import 'package:dotted_separator/dotted_separator.dart';
import 'package:flutter/material.dart';
import 'package:ski_tracker/utils/activity_database.dart';
import 'package:ski_tracker/utils/general_utils.dart';

import 'activity/activity_display.dart';
import 'main.dart';

class History extends StatefulWidget {
  const History({super.key});

  static const historyTitle = 'History';
  static const expandedHeight = ActivityDisplay.expandedHeight;

  static const double iconHeight = 64.0;

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  late final ScrollController _scrollController = ScrollController(
      initialScrollOffset: MediaQuery.sizeOf(context).height - 420);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          forceMaterialTransparency: true,
          collapsedHeight: MediaQuery.of(context).size.height -
              235,
          pinned: true,
          flexibleSpace: const Stack(
            children: [
              FlexibleSpaceBar(
                title: Text(History.historyTitle),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Stack(
                children: [
                  Container(
                    height: 650,
                    decoration:
                    const BoxDecoration(
                      color: ColorTheme.secondaryBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Status.heightBarContainer),
                        topRight: Radius.circular(Status.heightBarContainer),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        height: Status.heightBarContainer,
                        decoration: const BoxDecoration(
                          color: ColorTheme.secondaryBackgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(Status.heightBarContainer),
                            topRight: Radius.circular(Status.heightBarContainer),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          height: Status.heightBar,
                          width: Status.widthBar,
                          decoration: BoxDecoration(
                            color: ColorTheme.grey,
                            borderRadius: BorderRadius.circular(Status.heightBar / 2),
                          ),
                        ),
                      ),
                      Container(
                        color: ColorTheme.secondaryBackgroundColor,
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<List<ActivityDatabase>>(
                          // Assuming your activities() method returns a Future<List<ActivityDatabase>>
                          future: ActivityDatabaseHelper.activities(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              // While data is being fetched, display a loading indicator
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              // If there's an error, display an error message
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else {
                              // If data is successfully fetched, build the Column
                              List<ActivityDatabase>? activities = snapshot.data;

                              if (activities == null || activities.isEmpty) {
                                return const Center(
                                    child: Text('No activities found.'));
                              } else {
                                // Sort activities based on startTime in descending order
                                activities.sort((a, b) => b.startTime.compareTo(a.startTime));

                                return Column(
                                  children: activities
                                      .map((activity) => _buildItem(activity))
                                      .toList(),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
        // Fill remaining space
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(color: ColorTheme.secondaryBackgroundColor),
        ),
      ],
    );
  }

  Widget _buildItem(ActivityDatabase activity) {
    String startTime =
        '${DateTime.parse(activity.startTime).month}/${DateTime.parse(activity.startTime).day}/${DateTime.parse(activity.startTime).year}';
    String startTimeMinutes =
        '${DateTime.parse(activity.startTime).hour}:${DateTime.parse(activity.startTime).minute}';
    String endTimeMinutes =
        '${DateTime.parse(activity.endTime).hour}:${DateTime.parse(activity.endTime).minute}';

    return Column(
      children: [
        const SizedBox(height: 8.0),
        Container(
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: ColorTheme.secondaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: ColorTheme.primaryColor,
                      size: History.iconHeight / 4,
                    ),
                    const SizedBox(width: 4.0),
                    Utils.buildText(
                        text: activity.areaName != '' ? activity.areaName : 'Unknown',
                        fontSize: FontTheme.size,
                        fontWeight: FontWeight.bold,
                        color: ColorTheme.primaryColor),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: History.iconHeight,
                      height: History.iconHeight / 3 * 2,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.asset(
                          'assets/images/background.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Utils.buildText(
                              text: startTime,
                              fontSize: FontTheme.sizeSubHeader,
                              fontWeight: FontWeight.bold,
                              color: ColorTheme.contrastColor),
                          Row(
                            children: [
                              Utils.buildText(
                                  text: startTimeMinutes,
                                  fontSize: FontTheme.size,
                                  fontWeight: FontWeight.bold,
                                  color: ColorTheme.grey),
                              const SizedBox(width: 4.0),
                              Utils.buildText(
                                  text: '-',
                                  fontSize: FontTheme.size,
                                  fontWeight: FontWeight.bold,
                                  color: ColorTheme.grey),
                              const SizedBox(width: 4.0),
                              Utils.buildText(
                                  text: endTimeMinutes,
                                  fontSize: FontTheme.size,
                                  fontWeight: FontWeight.bold,
                                  color: ColorTheme.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    _buildHighlight('Distance',
                        '${(activity.distance / 1000).toStringAsFixed(2)} ${Info.unitDistance}'),
                    _buildHighlight('Duration',
                        '${activity.elapsedTime.substring(0, 4)} h'),
                    _buildHighlight('Speed',
                        '${activity.averageSpeed.toStringAsFixed(2)} ${Info.unitSpeed}'),
                  ],
                ),
              ],
            )),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildHighlight(String text, String value) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils.buildText(
            text: value,
            fontSize: FontTheme.size + 4,
            fontWeight: FontWeight.bold,
            color: ColorTheme.contrastColor,
            caps: false),
        Utils.buildText(
            text: text,
            fontSize: FontTheme.size - 4,
            fontWeight: FontWeight.bold,
            color: ColorTheme.grey),
      ],
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

}
