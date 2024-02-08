import 'package:flutter/material.dart';
import 'package:powder_pilot/ui/history/delete.dart';

import '../../../activity/database.dart';
import '../../../string_pool.dart';
import '../../../theme/color.dart';
import '../../../utils/general_utils.dart';
import '../../widgets/app_bar.dart';
import '../summary.dart';

/// A stateless widget for displaying a summary page of an activity.
class SummaryPage extends StatelessWidget {
  const SummaryPage({
    super.key,
    required this.activityDatabase,
    required this.onDelete,
  });

  final void Function() onDelete;

  final ActivityDatabase activityDatabase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomMaterialAppBar.appBar(
        title: StringPool.SUMMARY,
        child: PopupMenuButton<String>(
          color: ColorTheme.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onSelected: (value) {
            switch (value) {
              case 'delete':
                DeleteActivity.showDeleteConfirmationDialog(
                  context: context,
                  activity: activityDatabase,
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                );
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                height: 40,
                value: 'delete',
                child: Utils.buildText(text: StringPool.DELETE, caps: false, align: TextAlign.center),
              ),
              // Add more PopupMenuItems if needed
            ];
          },
        ),
      ),
      body: ActivitySummary(activityDatabase: activityDatabase),
    );
  }
}
