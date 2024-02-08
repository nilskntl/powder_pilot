import 'package:flutter/material.dart';

import 'color.dart';
import '../utils/general_utils.dart';
import 'animation.dart';

class WidgetTheme {
  /// Builds a ListTile used for the settings.
  static ListTile settingsListTile(
      {required String title,
        required Widget subtitle,
        Widget leading = const SizedBox(),
        required Function() onTap}) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Utils.buildText(
          text: title,
          caps: false,
          fontWeight: FontWeight.bold,
          align: TextAlign.left),
      subtitle: subtitle,
      leading: leading,
      onTap: () {
        onTap();
      },
    );
  }

  /// Builds a Dialog for the settings.
  static void settingsDialog(
      {required List<Widget> children,
        double height = 150,
        required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAnimatedWidget(
          child: Dialog(
            backgroundColor: ColorTheme.secondary,
            child: Container(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              height: height,
              child: ListView(
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }

  static ListTile settingsOption(
      {required String title,
        Widget subtitle = const SizedBox(),
        Widget leading = const SizedBox(),
        Widget trailing = const SizedBox(),
        required BuildContext context,
        required Function() onTap}) {
    if (subtitle is SizedBox && leading is SizedBox && trailing is SizedBox) {
      return ListTile(
          title:
          Utils.buildText(text: title, caps: false, align: TextAlign.left),
          dense: true,
          onTap: () {
            onTap();
            Navigator.pop(context);
          });
    } else if (leading is SizedBox && trailing is SizedBox) {
      return ListTile(
          title:
          Utils.buildText(text: title, caps: false, align: TextAlign.left),
          subtitle: subtitle,
          dense: true,
          onTap: () {
            onTap();
            Navigator.pop(context);
          });
    } else if (subtitle is SizedBox && trailing is SizedBox) {
      return ListTile(
          title:
          Utils.buildText(text: title, caps: false, align: TextAlign.left),
          leading: leading,
          dense: true,
          onTap: () {
            onTap();
            Navigator.pop(context);
          });
    } else if (leading is SizedBox) {
      return ListTile(
          title:
          Utils.buildText(text: title, caps: false, align: TextAlign.left),
          subtitle: subtitle,
          trailing: trailing,
          dense: true,
          onTap: () {
            onTap();
            Navigator.pop(context);
          });
    } else if (subtitle is SizedBox) {
      return ListTile(
          title:
          Utils.buildText(text: title, caps: false, align: TextAlign.left),
          leading: leading,
          trailing: trailing,
          dense: true,
          onTap: () {
            onTap();
            Navigator.pop(context);
          });
    } else {
      return ListTile(
          title:
          Utils.buildText(text: title, caps: false, align: TextAlign.left),
          subtitle: subtitle,
          leading: leading,
          trailing: trailing,
          dense: true,
          onTap: () {
            onTap();
            Navigator.pop(context);
          });
    }
  }

  /// Build the container used throughout widgets in the app.
  static Container container(
      {double height = -1.0,
        double width = -1.0,
        Color color = const Color(0xff000001),
        Alignment alignment = Alignment.center,
        BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16.0)),
        Widget child = const SizedBox(),
        EdgeInsets padding = const EdgeInsets.all(8.0)}) {
    if (color == const Color(0xff000001)) {
      color = ColorTheme.secondary;
    }
    if (height >= 0 && width >= 0) {
      return Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    } else if (height >= 0) {
      return Container(
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    } else if (width >= 0) {
      return Container(
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    } else {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    }
  }

  /// Build the animated container used throughout widgets in the app.
  static AnimatedContainer animatedContainer(
      {double height = -1.0,
        double width = -1.0,
        Duration duration = AnimationTheme.fastAnimationDuration,
        Curve curve = Curves.easeInOut,
        Color color = const Color(0xff000001),
        Alignment alignment = Alignment.center,
        BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16.0)),
        Widget child = const SizedBox(),
        EdgeInsets padding = const EdgeInsets.all(8.0),
        void Function()? onEnd}) {
    if (color == const Color(0xff000001)) {
      color = ColorTheme.secondary;
    }
    onEnd ??= () {};
    if (height >= 0 && width >= 0) {
      return AnimatedContainer(
        duration: duration,
        curve: curve,
        height: height,
        width: width,
        padding: padding,
        onEnd: onEnd,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    } else if (height >= 0) {
      return AnimatedContainer(
        duration: duration,
        curve: curve,
        height: height,
        onEnd: onEnd,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    } else if (width >= 0) {
      return AnimatedContainer(
        duration: duration,
        curve: curve,
        width: width,
        padding: padding,
        onEnd: onEnd,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    } else {
      return AnimatedContainer(
        duration: duration,
        curve: curve,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    }
  }
}