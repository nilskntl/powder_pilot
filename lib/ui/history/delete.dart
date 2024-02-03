import 'package:flutter/material.dart';

import '../../activity/database.dart';
import '../../string_pool.dart';
import '../../theme.dart';
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
              fontSize: FontTheme.sizeSubHeader),
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
                  color: ColorTheme.primary),
            ),
            TextButton(
              onPressed: () {
                _deleteActivity(activity.id);
                Navigator.of(context).pop();
                onPressed();
              },
              child: Utils.buildText(
                  text: StringPool.DELETE,
                  caps: false,
                  align: TextAlign.left,
                  color: ColorTheme.primary),
            ),
          ],
        );
      },
    );
  }

  /// Delete an activity from the database
  ///
  /// @param id The id of the activity to delete
  static void _deleteActivity(int id) {
    ActivityDatabaseHelper.deleteActivity(id);
  }
}
