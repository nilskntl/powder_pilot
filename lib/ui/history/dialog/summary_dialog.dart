import 'package:flutter/material.dart';

import '../../../activity/database.dart';
import '../../../string_pool.dart';
import '../../../theme.dart';
import '../../widgets/app_bar.dart';
import '../summary.dart';

/// A stateful widget for displaying a summary dialog of an activity.
class SummaryDialog extends StatefulWidget {
  const SummaryDialog({super.key, required this.activityDatabase});

  final ActivityDatabase activityDatabase;

  @override
  State<SummaryDialog> createState() => _SummaryDialogState();
}

class _SummaryDialogState extends State<SummaryDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: CustomMaterialAppBar.appBar(title: StringPool.SUMMARY),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: ColorTheme.background,
              ),
              child: ActivitySummary(
                activityDatabase: widget.activityDatabase,
                small: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}