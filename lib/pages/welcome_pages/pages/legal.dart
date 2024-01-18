import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/shared_preferences.dart';

class LegalPageButton extends StatefulWidget {
  const LegalPageButton(
      {super.key, required this.pageController, required this.currentPage});

  final PageController pageController;
  final int currentPage;

  @override
  State<LegalPageButton> createState() => _LegalPageButtonState();
}

class _LegalPageButtonState extends State<LegalPageButton> {
  String buttonText = 'Get started';

  late final double fontSize = Utils.calculateFontSizeByContext(
      text: 'I agree to the Terms of Service and Privacy Policy',
      context: context,
      standardFontSize: FontTheme.size,
      paddingLeftRight: 84);

  bool agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              value: agreedToTerms,
              onChanged: (value) {
                setState(() {
                  agreedToTerms = value ?? false;
                });
              },
            ),
            const SizedBox(width: 4),
            Flexible(
                child: Row(
              children: [
                Utils.buildText(
                  text: 'I agree to the ',
                  fontSize: fontSize,
                  fontWeight: FontWeight.normal,
                  color: ColorTheme.contrast,
                  caps: false,
                  align: TextAlign.left,
                ),
                GestureDetector(
                  onTap: () {
                    _showDialog(
                        context: context,
                        asset: 'assets/legal/terms_of_service.txt');
                  },
                  child: Utils.buildText(
                    text: 'Terms of Service',
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal,
                    color: ColorTheme.blue,
                    caps: false,
                    align: TextAlign.left,
                  ),
                ),
                Utils.buildText(
                  text: ' and ',
                  fontSize: fontSize,
                  fontWeight: FontWeight.normal,
                  color: ColorTheme.contrast,
                  caps: false,
                  align: TextAlign.left,
                ),
                GestureDetector(
                  onTap: () {
                    _showDialog(
                        context: context,
                        asset: 'assets/legal/privacy_policy.txt');
                  },
                  child: Utils.buildText(
                    text: 'Privacy Policy',
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal,
                    color: ColorTheme.blue,
                    caps: false,
                    align: TextAlign.left,
                  ),
                ),
              ],
            )),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 64.0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: () {
              if (agreedToTerms) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SkiTracker()));
                SharedPref.saveBool('welcome', true);
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: ColorTheme.contrast,
              backgroundColor:
                  agreedToTerms ? ColorTheme.primary : ColorTheme.grey,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Utils.buildText(
              text: buttonText,
              fontSize: FontTheme.size,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showDialog({required BuildContext context, required String asset}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LegalDialog(asset: asset);
      },
    );
  }
}

class LegalDialog extends StatefulWidget {
  const LegalDialog({super.key, required this.asset});

  final String asset;

  @override
  State<LegalDialog> createState() => _LegalDialogState();
}

class _LegalDialogState extends State<LegalDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  List<String> arr = [];

  @override
  void initState() {
    super.initState();

    loadTextFromAssets();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
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

  Future<void> loadTextFromAssets() async {
    String text = await rootBundle.loadString(widget.asset);
    List<String> paragraphs =
        text.split('\n').where((paragraph) => paragraph.isNotEmpty).toList();

    setState(() {
      arr = paragraphs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
          insetPadding: const EdgeInsets.all(16.0),
          backgroundColor: ColorTheme.background,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: ColorTheme.contrast,
                    ),
                  ),
                ),
                if (arr.isNotEmpty)
                  _buildDialogText(
                      text: arr.first, fontWeight: FontWeight.bold),
                const SizedBox(height: 12),
                ...arr
                    .skip(1)
                    .map((paragraph) => _buildDialogText(text: paragraph)),
              ],
            ),
          )),
    );
  }

  Widget _buildDialogText(
      {required String text, FontWeight fontWeight = FontWeight.normal}) {
    return Flexible(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils.buildText(
            text: text,
            fontSize: FontTheme.size,
            fontWeight: fontWeight,
            color: ColorTheme.contrast,
            align: TextAlign.left,
            caps: false),
        const SizedBox(height: 12),
      ],
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
