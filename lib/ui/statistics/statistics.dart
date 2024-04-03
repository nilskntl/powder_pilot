import 'package:flutter/material.dart';
import 'package:powder_pilot/ui/statistics/areas/most_visited_areas.dart';
import 'package:powder_pilot/ui/statistics/bests/bests.dart';
import 'package:powder_pilot/ui/statistics/distance/distances.dart';
import 'package:powder_pilot/ui/statistics/header/statistics_header.dart';

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
        const StatisticsHeader(),
        const Distances(),
        const SizedBox(height: 16),
        SizedBox(
          height: MediaQuery.of(context).size.height - 444,
          child: ListView(
            shrinkWrap: true,
            children: const [
              Column(
                children: [
                  Bests(),
                  SizedBox(height: 24),
                  MostVisitedAreas(),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
