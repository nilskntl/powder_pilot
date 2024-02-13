import 'package:flutter/material.dart';

import '../../activity/route.dart';
import '../../activity/slopes.dart';
import '../../activity/state.dart';
import '../../string_pool.dart';
import '../../theme/color.dart';
import '../../theme/font.dart';
import '../../utils/general_utils.dart';
import '../activity/status/status.dart';
import '../widgets/app_bar.dart';
import '../widgets/slope_circle.dart';
import 'map.dart';

class MapPage extends StatefulWidget {
  const MapPage(
      {super.key,
      this.status = ActivityStatus.running,
      required this.route,
      this.static = false,
      required this.activityMap});

  final ActivityMap activityMap;

  final ActivityStatus status;

  final ActivityRoute route;

  final bool static;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomMaterialAppBar.appBar(title: StringPool.MAP),
      body: Stack(
        children: [
          if (widget.status == ActivityStatus.inactive ||
              SlopeMap.slopes.isEmpty ||
              widget.route.slopes.isEmpty)
            widget.activityMap,
          if (widget.status != ActivityStatus.inactive &&
              SlopeMap.slopes.isNotEmpty &&
              widget.route.slopes.isNotEmpty)
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  forceMaterialTransparency: true,
                  flexibleSpace: widget.activityMap,
                  toolbarHeight: 125,
                  expandedHeight: MediaQuery.of(context).size.height -
                      172 -
                      MediaQuery.of(context).padding.bottom,
                  pinned: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Column(
                        children: [
                          Container(
                            height: Status.heightBarContainer,
                            decoration: BoxDecoration(
                              color: ColorTheme.background,
                              borderRadius: const BorderRadius.only(
                                topLeft:
                                    Radius.circular(Status.heightBarContainer),
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
                          Container(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                                bottom: 16,
                              ),
                              decoration: BoxDecoration(
                                color: ColorTheme.background,
                              ),

                              /// Make an entry for every route in the full route of widget.activityDataProvider.route except the last one
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ColorTheme.secondary,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        if (widget.route.slopes.isNotEmpty)
                                          SlopeCircle(
                                            slope: widget.route.slopes.last,
                                            animated: true,
                                          ),
                                        const SizedBox(width: 16),
                                        if (widget.route.slopes.isNotEmpty)
                                          SlopeCircle.buildSlopeName(
                                              slope: widget.route.slopes.last),
                                        const Spacer(),
                                        Container(
                                          height: 24,
                                          width: 96,
                                          decoration: BoxDecoration(
                                            color: ColorTheme.green,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          alignment: Alignment.center,
                                          child: Utils.buildText(
                                              text: 'Current',
                                              fontSize: FontTheme.size - 4,
                                              color: ColorTheme.secondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    reverse: true,
                                    itemCount: widget.route.slopes.length,
                                    itemBuilder: (context, index) {
                                      if (index !=
                                          widget.route.slopes.length - 1) {
                                        return Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: ColorTheme.secondary,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SlopeCircle(
                                                  slope: widget
                                                      .route.slopes[index]),
                                              const SizedBox(width: 16),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Utils.buildText(
                                                          text: 'Start: ',
                                                          fontSize:
                                                              FontTheme.size -
                                                                  4,
                                                          color:
                                                              ColorTheme.grey,
                                                          caps: false),
                                                      const SizedBox(width: 4),
                                                      Utils.buildText(
                                                          text: Utils.durationStringToString(widget
                                                              .route
                                                              .slopes[index]
                                                              .startTime
                                                              .toString())[1],
                                                          caps: false,
                                                          fontSize:
                                                              FontTheme.size -
                                                                  4,
                                                          color: ColorTheme
                                                              .contrast),
                                                    ],
                                                  ),
                                                  SlopeCircle.buildSlopeName(
                                                      slope: widget
                                                          .route.slopes[index]),
                                                  Row(
                                                    children: [
                                                      Utils.buildText(
                                                          text: 'Duration: ',
                                                          fontSize:
                                                              FontTheme.size -
                                                                  4,
                                                          color:
                                                              ColorTheme.grey,
                                                          caps: false),
                                                      const SizedBox(width: 4),
                                                      Utils.buildText(
                                                          text: Utils.formatDuration(widget
                                                                  .route
                                                                  .slopes[index]
                                                                  .endTime
                                                                  .difference(widget
                                                                      .route
                                                                      .slopes[
                                                                          index]
                                                                      .startTime)) +
                                                              ' min',
                                                          caps: false,
                                                          fontSize:
                                                              FontTheme.size -
                                                                  4,
                                                          color: ColorTheme
                                                              .contrast),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: ColorTheme.background,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
