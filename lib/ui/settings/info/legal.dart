import 'package:flutter/material.dart';

import '../../../string_pool.dart';
import '../../../theme/color.dart';
import '../../../utils/general_utils.dart';
import '../../welcome_pages/welcome_page.dart';

class LegalSetting extends StatelessWidget {
  const LegalSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: TextButton(
            onPressed: () {
              _showDialog(
                  context: context, asset: 'assets/legal/privacy_policy.txt');
            },
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.5)),
            ),
            child: Utils.buildText(
              text: StringPool.PRIVACY_POLICY,
              color: ColorTheme.grey,
              caps: false,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Flexible(
          child: TextButton(
            onPressed: () {
              _showDialog(
                  context: context, asset: 'assets/legal/terms_of_service.txt');
            },
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.5)),
            ),
            child: Utils.buildText(
              text: StringPool.TERMS_OF_SERVICE,
              color: ColorTheme.grey,
              caps: false,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  /// Shows a legal text dialog.
  void _showDialog({required BuildContext context, required String asset}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LegalDialog(asset: asset);
      },
    );
  }
}
