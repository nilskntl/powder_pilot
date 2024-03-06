import 'package:flutter/cupertino.dart';

/// Class to encapsulate properties of animations used in the app.
class AnimationTheme {
  static const Duration animationDuration = Duration(milliseconds: 500);
  static const Duration fastAnimationDuration = Duration(milliseconds: 350);
}

/// Displays a widget that pops in with a scale animation.
class CustomAnimatedWidget extends StatefulWidget {
  const CustomAnimatedWidget(
      {super.key,
      required this.child,
      this.duration = AnimationTheme.fastAnimationDuration});

  /// The child widget to animate
  final Widget child;
  /// The duration of the animation (default: animationDuration)
  final Duration duration;

  @override
  State<CustomAnimatedWidget> createState() => _CustomAnimatedWidgetState();
}

class _CustomAnimatedWidgetState extends State<CustomAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
