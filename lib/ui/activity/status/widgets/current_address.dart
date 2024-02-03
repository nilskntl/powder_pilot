import 'package:flutter/cupertino.dart';
import 'package:powder_pilot/activity/data_provider.dart';

import '../../../../string_pool.dart';
import '../../../../theme.dart';
import '../../../../utils/general_utils.dart';

/// The current address shows the current address of the user.
/// The address is updated regularly if internet is available.
/// Format: Icon + Address (Country, City)
class CurrentAddress extends StatefulWidget {
  const CurrentAddress({super.key, required this.dataProvider});

  /// The data provider for the activity
  final ActivityDataProvider dataProvider;

  @override
  State<CurrentAddress> createState() => _CurrentAddressState();
}

/// The state of the current address
class _CurrentAddressState extends State<CurrentAddress> {
  /// Which icon to show
  IconData _icon() {
    if (!widget.dataProvider.internetStatus) {
      return LogoTheme.noInternet;
    } else {
      return LogoTheme.gps;
    }
  }

  /// The color of the address and icon
  Color _color() {
    if (widget.dataProvider.area != '') {
      return ColorTheme.primary;
    } else {
      return ColorTheme.grey;
    }
  }

  /// The text of the address
  String _text() {
    if (widget.dataProvider.area != '') {
      return widget.dataProvider.area;
    } else {
      return StringPool.UNKNOWN_AREA;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 4),
        Icon(
          _icon(),
          size: FontTheme.sizeSubHeader,
          color: _color(),
        ),
        const SizedBox(width: 4),
        Utils.buildText(
          text: _text(),
          fontSize: FontTheme.size,
          color: _color(),
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
