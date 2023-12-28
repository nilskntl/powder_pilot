import 'package:flutter/material.dart';

import '../main.dart';
import '../utils.dart';

class ActivityBar extends StatefulWidget {
  @override
  _ActivityBarState createState() => _ActivityBarState();

  void startActivity() {
    SkiTracker.startActivity();
  }
}

class _ActivityBarState extends State<ActivityBar> {
  @override
  Widget build(BuildContext context) {
    if (SkiTracker.getActivity().isRunning()) {
      return _runningActivity();
    } else {
      return _startActivity();
    }
  }

  Widget _startActivity() {
    return GestureDetector(
      onTap: () {
        widget.startActivity();
        setState(() {
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: ColorTheme.primaryColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.play_arrow_rounded,
              size: 64,
              color: ColorTheme.contrastColor,
            ),
            Utils.buildText(text: 'Start Activity'),
          ],
        ),
      ),
    );
  }

  Widget _runningActivity() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              SkiTracker.stopActivity();
              setState(() {
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: ColorTheme.primaryColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.stop_rounded,
                    size: 64,
                    color: ColorTheme.contrastColor,
                  ),
                  Utils.buildText(text: 'End Activity'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
