import 'package:flutter/material.dart';

import '../main.dart';
import '../utils.dart';
import 'activity_data_provider.dart';

class ActivityBar extends StatefulWidget {
  const ActivityBar({super.key, required this.activityDataProvider});

  final ActivityDataProvider activityDataProvider;

  @override
  State<ActivityBar> createState() => _ActivityBarState();
}

class _ActivityBarState extends State<ActivityBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(0.0),
            margin: const EdgeInsets.all(16.0),
            width: SkiTracker.getActivity().isActive
                ? MediaQuery.sizeOf(context).width
                : 0,
            decoration: BoxDecoration(
              color: ColorTheme.primaryColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: _running()),
        Container(
          padding: const EdgeInsets.all(8.0),
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: ColorTheme.primaryColor,
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: GestureDetector(
              onTap: () {
                if (!SkiTracker.getActivity().isActive) {
                  SkiTracker.getActivity().startActivity();
                } else if (SkiTracker.getActivity().isRunning) {
                  SkiTracker.getActivity().pauseActivity();
                } else {
                  SkiTracker.getActivity().resumeActivity();
                }
                setState(() {});
              },
              child: Stack(
                children: [
                  if (SkiTracker.getActivity().isRunning)
                    const Icon(
                      Icons.pause_rounded,
                      size: 64,
                      color: ColorTheme.contrastColor,
                    ),
                  if (!SkiTracker.getActivity().isRunning)
                    const Icon(
                      Icons.play_arrow_rounded,
                      size: 64,
                      color: ColorTheme.contrastColor,
                    ),
                ],
              )),
        ),
      ],
    );
  }

  Widget _running() {
    if (SkiTracker.getActivity().isActive) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 16),
              Utils.buildText(
                  fontSize: FontTheme.sizeSubHeader,
                  text: SkiTracker.getActivityDataProvider()
                      .elapsedTime
                      .toString()
                      .substring(0, 7)),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  SkiTracker.getActivity().stopActivity();
                  setState(() {});
                },
                child: const Icon(
                  Icons.stop_rounded,
                  size: 48,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(width: 8),
            ]
          )
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _runningActivity() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
                      Utils.buildText(
                          text: widget.activityDataProvider.elapsedTime
                              .toString()
                              .substring(0, 7)),
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
                        Utils.buildText(text: 'End Activity')
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
