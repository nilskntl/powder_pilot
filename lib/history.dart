import 'package:flutter/material.dart';
import 'package:ski_tracker/utils.dart';

import 'main.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: ColorTheme.backgroundColor,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Utils.buildText(text: 'Test'),
          ],
        ),
    );
  }
}
