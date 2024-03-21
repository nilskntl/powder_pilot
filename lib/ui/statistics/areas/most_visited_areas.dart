import 'package:flutter/cupertino.dart';
import 'package:powder_pilot/main.dart';
import 'package:powder_pilot/ui/widgets/bar_graph.dart';

import '../../../string_pool.dart';
import '../../../theme/color.dart';
import '../../../theme/font.dart';
import '../../../utils/general_utils.dart';
import '../utils/material_text_button.dart';

class MostVisitedAreas extends StatelessWidget {
  const MostVisitedAreas({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MaterialTextButton(
          text: StringPool.MOST_VISITED_AREAS,
          color: ColorTheme.secondary,
        ),
        const SizedBox(height: 8),
        if (PowderPilot.pastActivities.mostVisitedAreas().isNotEmpty)
          SizedBox(
            height: 200,
            child: Row(
              children: [
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: BarGraph(
                    map: PowderPilot.pastActivities.mostVisitedAreas(),
                    barColor: ColorTheme.primary,
                    titleColor: ColorTheme.grey,
                  ),
                ),
                const SizedBox(
                  width: 8.0,
                ),
              ],
            ),
          )
        else
          Utils.buildText(
            text: StringPool.NO_DATA,
            color: ColorTheme.grey,
            fontSize: FontTheme.size,
            caps: false,
          ),
      ],
    );
  }
}
