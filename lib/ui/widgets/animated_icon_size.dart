import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../theme.dart';

/// Class to animate the size of an icon
class AnimatedIconSize extends StatefulWidget {
  const AnimatedIconSize({super.key, required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  State<AnimatedIconSize> createState() => _AnimatedIconSizeState();
}

class _AnimatedIconSizeState extends State<AnimatedIconSize> {
  late double _currentSize = widget.size;
  late double _targetSize = widget.size;

  late final Duration _duration = AnimationTheme.animationDuration;
  late final Duration _updateDuration = const Duration(milliseconds: 10);

  void _startAnimation() async {
    double diff = (_targetSize - _currentSize).abs();
    double diffPerUpdate =
        diff / (_duration.inMilliseconds / _updateDuration.inMilliseconds);
    Timer.periodic(_updateDuration, (timer) {
      if (_currentSize < _targetSize) {
        _currentSize += diffPerUpdate;
        if (_currentSize > _targetSize) _currentSize = _targetSize;
      } else if (_currentSize > _targetSize) {
        _currentSize -= diffPerUpdate;
        if (_currentSize < _targetSize) _currentSize = _targetSize;
      }
      setState(() {});
      if ((_currentSize - _targetSize).abs() < 0.1) {
        _currentSize = _targetSize;
        setState(() {});
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_targetSize != widget.size) {
      _targetSize = widget.size;
      _startAnimation();
    }
    return Icon(
      widget.icon,
      size: _currentSize,
      color: ColorTheme.secondary,
    );
  }
}
