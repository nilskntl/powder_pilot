import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ski_tracker/utils.dart';

import 'main.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  _SelectPageState createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _animateToPage(1);
                },
                child: _buildSelectPageContainer(
                    iconData: Icons.downhill_skiing_rounded, text: 'Activity'),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _animateToPage(2);
                },
                child: _buildSelectPageContainer(
                    iconData: Icons.calendar_month_rounded, text: 'History'),
              ),
            ),
          ],
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          top: 0,
          left: (MediaQuery.of(context).size.width / SkiTracker.getMainWidgetState().numberPages) *
              (SkiTracker.getMainWidgetState().currentPage - 1),
          child: Container(
            width: MediaQuery.of(context).size.width / SkiTracker.getMainWidgetState().numberPages,
            height: 4,
            color: ColorTheme.contrastColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectPageContainer(
      {required IconData iconData, required String text}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: ColorTheme.primaryColor,
      child: Column(
        children: [
          Icon(
            iconData,
            size: 32,
            color: ColorTheme.contrastColor,
          ),
          Utils.buildText(text: text),
        ],
      ),
    );
  }

  void _animateToPage(int page) {
    setState(() {
      SkiTracker.getMainWidgetState().currentPage = page;
      SkiTracker.getMainWidgetState().update();
    });
  }

}