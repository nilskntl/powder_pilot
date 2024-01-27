import 'package:flutter/material.dart';

import '../activity/database.dart';
import '../theme.dart';
import '../utils/general_utils.dart';
import 'activity_page.dart';
import 'activity_summary.dart';

class History extends StatefulWidget {
  const History({super.key});

  static const historyTitle = 'History';
  static const expandedHeight = ActivityPage.expandedHeight;

  static const double iconHeight = 64.0;

  static void showDeleteConfirmationDialog(BuildContext context,
      ActivityDatabase activity, void Function() onPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Utils.buildText(
              text: 'Delete activity?',
              caps: false,
              align: TextAlign.left,
              fontWeight: FontWeight.bold,
              fontSize: FontTheme.sizeSubHeader),
          content: Utils.buildText(
              text: 'Do you really want to delete this activity?',
              caps: false,
              align: TextAlign.left),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Utils.buildText(
                  text: 'Cancel',
                  caps: false,
                  align: TextAlign.left,
                  color: ColorTheme.primary),
            ),
            TextButton(
              onPressed: () {
                _deleteActivity(activity);
                Navigator.of(context).pop();
                onPressed();
              },
              child: Utils.buildText(
                  text: 'Delete',
                  caps: false,
                  align: TextAlign.left,
                  color: ColorTheme.primary),
            ),
          ],
        );
      },
    );
  }

  static void _deleteActivity(ActivityDatabase activity) {
    ActivityDatabaseHelper.deleteActivity(activity.id);
  }

  @override
  State<History> createState() => HistoryState();
}

class HistoryState extends State<History> {
  late final ScrollController _scrollController = ScrollController(
      initialScrollOffset: MediaQuery.sizeOf(context).height - 420);

  void update() {
    setState(() {});
  }

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
              255 -
              MediaQuery.of(context).padding.bottom,
          pinned: true,
          flexibleSpace: const Stack(
            children: [],
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Stack(
                children: [
                  Container(
                    height: 650,
                    decoration: const BoxDecoration(
                      color: ColorTheme.background,
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
                          color: ColorTheme.background,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(Status.heightBarContainer),
                            topRight:
                                Radius.circular(Status.heightBarContainer),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          height: Status.heightBar,
                          width: Status.widthBar,
                          decoration: BoxDecoration(
                            color: ColorTheme.grey,
                            borderRadius:
                                BorderRadius.circular(Status.heightBar / 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        color: ColorTheme.background,
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<List<ActivityDatabase>>(
                          // Assuming your activities() method returns a Future<List<ActivityDatabase>>
                          future: ActivityDatabaseHelper.activities(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // While data is being fetched, display a loading indicator
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              // If there's an error, display an error message
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else {
                              // If data is successfully fetched, build the Column
                              List<ActivityDatabase>? activities =
                                  snapshot.data;

                              if (activities == null || activities.isEmpty) {
                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const SizedBox(width: 8.0),
                                        Container(
                                          width: History.iconHeight,
                                          height: History.iconHeight,
                                          decoration: const BoxDecoration(
                                            color: ColorTheme.primary,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  History.iconHeight / 4),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_month_rounded,
                                            color: ColorTheme.secondary,
                                            size: History.iconHeight - 24,
                                          ),
                                        ),
                                        const SizedBox(width: 24.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Utils.buildText(
                                                  text: '0',
                                                  fontSize: FontTheme.size + 4,
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorTheme.contrast),
                                              Utils.buildText(
                                                  text: 'Activities',
                                                  fontSize: FontTheme.size,
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorTheme.grey),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32.0),
                                    const Center(
                                        child: Text('No activities found.')),
                                  ],
                                );
                              } else {
                                // Sort activities based on startTime in descending order
                                activities.sort((a, b) =>
                                    b.startTime.compareTo(a.startTime));

                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const SizedBox(width: 8.0),
                                        Container(
                                          width: History.iconHeight,
                                          height: History.iconHeight,
                                          decoration: const BoxDecoration(
                                            color: ColorTheme.primary,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  History.iconHeight / 4),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_month_rounded,
                                            color: ColorTheme.secondary,
                                            size: History.iconHeight - 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Utils.buildText(
                                                          text: activities
                                                              .length
                                                              .toString(),
                                                          fontSize:
                                                              FontTheme.size,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: ColorTheme
                                                              .contrast),
                                                      Utils.buildText(
                                                          text: 'Activities',
                                                          fontSize:
                                                              FontTheme.size -
                                                                  4,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              ColorTheme.grey),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Utils.buildText(
                                                          text: Utils.durationStringToString(
                                                                  activities
                                                                      .first
                                                                      .startTime)[
                                                              0],
                                                          fontSize:
                                                              FontTheme.size,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: ColorTheme
                                                              .contrast),
                                                      Utils.buildText(
                                                          text: 'Latest',
                                                          fontSize:
                                                              FontTheme.size -
                                                                  4,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              ColorTheme.grey),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Utils.buildText(
                                                          text: Utils.durationStringToString(
                                                                  activities
                                                                      .last
                                                                      .startTime)[
                                                              0],
                                                          fontSize:
                                                              FontTheme.size,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: ColorTheme
                                                              .contrast),
                                                      Utils.buildText(
                                                          text: 'Earliest',
                                                          fontSize:
                                                              FontTheme.size -
                                                                  4,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              ColorTheme.grey),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                      ],
                                    ),
                                    const SizedBox(height: 16.0),
                                    Column(
                                      children: activities
                                          .map((activity) =>
                                              _buildItem(activity))
                                          .toList(),
                                    ),
                                  ],
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
          child: Container(color: ColorTheme.background),
        ),
      ],
    );
  }

  Widget _buildItem(ActivityDatabase activity) {
    return GestureDetector(
      onLongPress: () {
        History.showDeleteConfirmationDialog(context, activity, () {
          setState(() {});
        });
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryPage(
              activityDatabase: activity,
              historyState: this,
            ),
          ),
        );
      },
      child: Column(
        children: [
          const SizedBox(height: 8.0),
          Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: ColorTheme.secondary,
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: ColorTheme.primary,
                        size: History.iconHeight / 4,
                      ),
                      const SizedBox(width: 4.0),
                      Utils.buildText(
                          text: activity.areaName != ''
                              ? activity.areaName
                              : 'Unknown',
                          fontSize: FontTheme.size,
                          fontWeight: FontWeight.bold,
                          color: ColorTheme.primary),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Container(
                        width: History.iconHeight - 12,
                        height: History.iconHeight - 12,
                        decoration: const BoxDecoration(
                            color: ColorTheme.primary,
                            borderRadius: BorderRadius.all(
                              Radius.circular(16.0),
                            )),
                        child: const Icon(
                          Icons.downhill_skiing_rounded,
                          color: ColorTheme.secondary,
                          size: History.iconHeight - 36,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Utils.buildText(
                                text: Utils.durationStringToString(
                                    activity.startTime)[0],
                                fontSize: FontTheme.sizeSubHeader,
                                fontWeight: FontWeight.bold,
                                color: ColorTheme.contrast),
                            Row(
                              children: [
                                Utils.buildText(
                                    text: Utils.durationStringToString(
                                        activity.startTime)[1],
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
                                    text: Utils.durationStringToString(
                                        activity.endTime)[1],
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
                          '${(activity.distance * Info.distanceFactor / 1000).toStringAsFixed(1)} ${Info.unitDistance}'),
                      _buildHighlight('Duration',
                          '${activity.elapsedTime.substring(0, 4)} h'),
                      _buildHighlight('Speed',
                          '${(activity.maxSpeed * Info.speedFactor).toStringAsFixed(1)} ${Info.unitSpeed}'),
                    ],
                  ),
                ],
              )),
          const SizedBox(height: 8.0),
        ],
      ),
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
            color: ColorTheme.contrast,
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
