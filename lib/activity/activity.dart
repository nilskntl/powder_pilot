import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ski_tracker/utils.dart';

import '../main.dart';

class Activity {

  // Stream Position
  late StreamSubscription<Position> locationSubscription;
  final StreamController<Position> _locationStreamController =
  StreamController<Position>.broadcast();

  bool _isLocationLoaded = false;

  late Position _currentPosition;
  double _maxSpeed = 0.0;
  double _avgSpeed = 0.0;
  double _totalDistance = 0.0;
  double _uphillDistance = 0.0;
  double _downhillDistance = 0.0;

  bool isLocationLoaded() {
    return _isLocationLoaded;
  }

  void startActivity() {
    _startLocationStream();
  }

  Position getCurrentPosition() {
    return _currentPosition;
  }

  double getMaxSpeed() {
    return _maxSpeed;
  }

  double getAvgSpeed() {
    return _avgSpeed;
  }

  double getTotalDistance() {
    return _totalDistance;
  }

  double getUphillDistance() {
    return _uphillDistance;
  }

  double getDownhillDistance() {
    return _downhillDistance;
  }

  void _startLocationStream() {
    locationSubscription =
        Geolocator.getPositionStream().listen((Position position) {

          _isLocationLoaded = true;
          _currentPosition = position;
          _locationStreamController.add(position);

          print(_currentPosition);
          print(_currentPosition.speed);
          print(_currentPosition.altitude);

          // Update speed
          double currentSpeed = position.speed;
          _maxSpeed = currentSpeed > _maxSpeed ? currentSpeed : _maxSpeed;
          _avgSpeed = (_avgSpeed + currentSpeed) / 2;

          // Update distances
          if (_currentPosition.speed > 0) {
            _totalDistance += _currentPosition.speed / 3.6; // Convert m/s to km/h
            _downhillDistance += _currentPosition.speed / 3.6;
          } else {
            _uphillDistance -= _currentPosition.speed / 3.6;
          }
          // Update UI
          SkiTracker.getActivityState().setState(() {});

        }, onError: (error) {
          if (kDebugMode) {
            print('Error in location stream: $error');
          }
        });
  }

}

class ActivityWidget extends StatefulWidget {
  const ActivityWidget({super.key});

  @override
  State<ActivityWidget> createState() => ActivityWidgetState();
}

class ActivityWidgetState extends State<ActivityWidget> {

  @override
  void initState() {
    super.initState();
    SkiTracker.setActivityState(this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: _buildActivityContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Utils.buildText(text: 'Speed'),
                        const Icon(
                          Icons.speed_rounded,
                          size: 32,
                          color: ColorTheme.contrastColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Utils.buildText(text: SkiTracker.getActivity().isLocationLoaded()
                        ? '${(SkiTracker.getActivity().getCurrentPosition().speed * 3.6).toStringAsFixed(1)} km/h'
                            : '-.-',
                            fontSize: FontTheme.sizeSubHeader),
                      ],
                    ),
                    Row(
                      children: [
                        Utils.buildText(text: 'Max'),
                        const Spacer(),
                        Utils.buildText(text: SkiTracker.getActivity().isLocationLoaded() ? '${SkiTracker.getActivity().getMaxSpeed().toStringAsFixed(1)} km/h' : '-.-', fontWeight: FontWeight.bold),
                        const SizedBox(width: 4),
                      ],
                    ),
                    Row(
                      children: [
                        Utils.buildText(text: 'Avg'),
                        const Spacer(),
                        Utils.buildText(text: SkiTracker.getActivity().isLocationLoaded() ? '${SkiTracker.getActivity().getAvgSpeed().toStringAsFixed(1)} km/h' : '-.-', fontWeight: FontWeight.bold),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActivityContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Utils.buildText(text: 'Distance'),
                        const Icon(
                          Icons.map_rounded,
                          size: 32,
                          color: ColorTheme.contrastColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Utils.buildText(text: SkiTracker.getActivity().isLocationLoaded() ? '${SkiTracker.getActivity().getTotalDistance().toStringAsFixed(1)} km' : '-.-',
                            fontSize: FontTheme.sizeSubHeader),
                      ],
                    ),
                    Row(
                      children: [
                        Utils.buildText(text: 'Downhill'),
                        const Spacer(),
                        Utils.buildText(text: SkiTracker.getActivity().isLocationLoaded() ? '${SkiTracker.getActivity().getDownhillDistance().toStringAsFixed(1)} km' : '-.-', fontWeight: FontWeight.bold),
                        const SizedBox(width: 4),
                      ],
                    ),
                    Row(
                      children: [
                        Utils.buildText(text: 'Uphill'),
                        const Spacer(),
                        Utils.buildText(text: SkiTracker.getActivity().isLocationLoaded() ? '${SkiTracker.getActivity().getUphillDistance().toStringAsFixed(1)} km' : '-.-', fontWeight: FontWeight.bold),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: ColorTheme.primaryColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: child,
    );
  }

}