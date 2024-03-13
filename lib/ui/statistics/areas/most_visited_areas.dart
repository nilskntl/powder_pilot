import 'package:flutter/cupertino.dart';
import 'package:powder_pilot/main.dart';
import 'package:powder_pilot/ui/widgets/bar_graph.dart';

import '../../../theme/color.dart';

class MostVisitedAreas extends StatelessWidget {
  const MostVisitedAreas({super.key});

  @override
  Widget build(BuildContext context) {
    return BarGraph(
      map: PowderPilot.pastActivities.mostVisitedAreas(),
      barColor: ColorTheme.primary,
      titleColor: ColorTheme.grey,
    );
  }
}
