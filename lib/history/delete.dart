import 'package:flutter/material.dart';
import 'package:powder_pilot/main.dart';

import '../../activity/database.dart';
import '../../string_pool.dart';
import '../../theme/color.dart';
import '../../theme/font.dart';
import '../../utils/general_utils.dart';

/// Class to handle the deletion of an activity
class DeleteActivity {
  /// Show a dialog to confirm the deletion of an activity
  ///
  /// @param context The context of the widget
  /// @param activity The activity to delete
  /// @param onPressed The function to execute when the activity is deleted
  static void showDeleteConfirmationDialog(
      {required BuildContext context,
      required ActivityDatabase activity,
      required void Function() onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Utils.buildText(
            text: StringPool.DELETE_ACTIVITY,
            caps: false,
            align: TextAlign.left,
            fontWeight: FontWeight.bold,
            fontSize: FontTheme.sizeSubHeader,
          ),
          content: Utils.buildText(
              text: StringPool.DELETE_ACTIVITY_CONFIRMATION,
              caps: false,
              align: TextAlign.left),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Utils.buildText(
                text: StringPool.CANCEL,
                caps: false,
                align: TextAlign.left,
                color: ColorTheme.primary,
              ),
            ),
            TextButton(
              onPressed: () {
                PowderPilot.pastActivities.removeActivity(activity.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Utils.buildText(
                      text: StringPool.SUCCESSFULLY_DELETED,
                      fontWeight: FontWeight.bold,
                      caps: false,
                    ),
                    backgroundColor: ColorTheme.secondary,
                    elevation: 4,
                    showCloseIcon: true,
                    closeIconColor: ColorTheme.contrast,
                    duration: const Duration(seconds: 3), // Set the duration
                  ),
                );
                onPressed();
              },
              child: Utils.buildText(
                text: StringPool.DELETE,
                caps: false,
                align: TextAlign.left,
                color: ColorTheme.primary,
              ),
            ),
          ],
        );
      },
    );
  }
}
