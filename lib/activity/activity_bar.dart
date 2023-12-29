import 'package:flutter/material.dart';

import '../main.dart';
import '../utils.dart';

class ActivityBar extends StatefulWidget {
  const ActivityBar({super.key});

  @override
  State<ActivityBar> createState() => _ActivityBarState();

  void startActivity() {
    SkiTracker.startActivity();
  }
}

class _ActivityBarState extends State<ActivityBar> {
  @override
  Widget build(BuildContext context) {
    if (SkiTracker.getActivity().isActive) {
      return _runningActivity();
    } else {
      return _startActivity();
    }
  }

  Widget _startActivity() {
    return GestureDetector(
      onTap: () {
        widget.startActivity();
        setState(() {});
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
          child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: ColorTheme.primaryColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.timer_rounded,
                        size: 48,
                        color: ColorTheme.contrastColor,
                      ),
                      Utils.buildText(text: 'Time'),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      SkiTracker.getActivity().isRunning
                          ? SkiTracker.getActivity().pauseActivity()
                          : SkiTracker.getActivity().resumeActivity();
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        Icon(
                          SkiTracker.getActivity().isRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 48,
                          color: ColorTheme.contrastColor,
                        ),
                        Utils.buildText(
                            text: SkiTracker.getActivity().isRunning
                                ? 'Pause Activity'
                                : 'Resume Activity'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      SkiTracker.getActivity().stopActivity();
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        const Icon(
                      Icons.stop_rounded,
                          size: 48,
                          color: ColorTheme.contrastColor,
                        ),
                        Utils.buildText(
                            text: 'End Activity')
                      ],
                    ),
                  ),
                ],
              )),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
