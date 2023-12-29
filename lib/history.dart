import 'package:flutter/material.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'History',
          style: TextStyle(
            fontSize: 32,
            color: Colors.deepPurple,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 32,
                  color: Colors.deepPurple,
                ),
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Icon(
                  Icons.calendar_view_month_rounded,
                  size: 32,
                  color: Colors.deepPurple,
                ),
                Text(
                  'Month',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Icon(
                  Icons.calendar_view_week_rounded,
                  size: 32,
                  color: Colors.deepPurple,
                ),
                Text(
                  'Week',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
