import 'package:flutter/cupertino.dart';

/// A widget that displays the number of activities.
class NumberActivities extends StatefulWidget {
  const NumberActivities({super.key});

  @override
  State<NumberActivities> createState() => _NumberActivitiesState();
}

/// The state for the NumberActivities widget.
class _NumberActivitiesState extends State<NumberActivities> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Number of activities:'),
        const Text('0'),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
