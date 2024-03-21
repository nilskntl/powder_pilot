import 'package:flutter/material.dart';

import '../../../theme/color.dart';
import '../../../theme/font.dart';
import '../../../utils/general_utils.dart';

class MaterialTextButton extends StatelessWidget {
  const MaterialTextButton({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: MaterialButton(
            onPressed: () {},
            color: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            splashColor: ColorTheme.grey.withOpacity(0.2),
            child: Utils.buildText(
              text: text,
              fontSize: FontTheme.size,
              fontWeight: FontWeight.bold,
              color: ColorTheme.grey,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
