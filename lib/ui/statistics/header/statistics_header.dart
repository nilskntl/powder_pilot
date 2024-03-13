import 'package:flutter/cupertino.dart';
import 'package:powder_pilot/theme/font.dart';

import '../../../string_pool.dart';
import '../../../theme/color.dart';
import '../../../theme/icon.dart';
import '../../../utils/general_utils.dart';

class StatisticsHeader extends StatelessWidget {
  const StatisticsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          Icon(
            LogoTheme.statistics,
            size: 64,
            color: ColorTheme.primary,
          ),
          const Spacer(),
          Column(
            children: [
              const SizedBox(height: 8),
              Utils.buildText(
                text: StringPool.STATISTICS,
                color: ColorTheme.grey,
                fontSize: FontTheme.sizeSubHeader - 4,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
