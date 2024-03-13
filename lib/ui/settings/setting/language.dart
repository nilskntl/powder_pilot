import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:powder_pilot/main.dart';
import 'package:powder_pilot/ui/settings/settings.dart';
import 'package:powder_pilot/ui/statistics/statistics.dart';

import '../../../l10n/messages_all_locales.dart';
import '../../../string_pool.dart';
import '../../../theme/color.dart';
import '../../../theme/widget.dart';
import '../../../utils/general_utils.dart';
import '../../activity/activity_page.dart';

/// The language setting allows the user to change the language of the app.
class LanguageSetting extends StatefulWidget {
  const LanguageSetting({super.key});

  @override
  State<LanguageSetting> createState() => _LanguageSettingState();
}

/// The state of the language setting
class _LanguageSettingState extends State<LanguageSetting> {
  /// Switches the language of the app
  ///
  /// [language] The language to switch to (e.g. 'en')
  void _switchLanguage(String language) async {
    if (kDebugMode) {
      print('Switching language to $language');
    }

    /// Set the language of the app
    Intl.defaultLocale = language;
    PowderPilot.setLanguage(language);
    await initializeMessages(language);

    /// Reload the app
    setState(() {
      SettingsPage.reload();
      PowderPilot.reload();
      ActivityPage.reload();
      StatisticsPage.reload();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetTheme.settingsListTile(
      title: StringPool.LANGUAGE,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CountryFlag.fromCountryCode(
          PowderPilot.language[0] == 'en' ? 'gb' : PowderPilot.language[0],
          height: SettingsPage.leadingWidget / 3 * 2,
          width: SettingsPage.leadingWidget,
          borderRadius: 0.0,
        ),
      ),
      subtitle: Utils.buildText(
        text: PowderPilot.language[1],
        caps: false,
        color: ColorTheme.contrast,
        align: TextAlign.left,
      ),
      onTap: () {
        WidgetTheme.settingsDialog(
          height: MediaQuery.of(context).size.height / 2,
          children: PowderPilot.availableLanguages
              .map(
                (language) => Column(
                  children: [
                    WidgetTheme.settingsOption(
                      title: language[1],
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CountryFlag.fromCountryCode(
                          language[0] == 'en' ? 'gb' : language[0],
                          height: SettingsPage.leadingWidget / 3 * 2,
                          width: SettingsPage.leadingWidget,
                          borderRadius: 0.0,
                        ),
                      ),
                      context: context,
                      onTap: () {
                        _switchLanguage(
                          language[0],
                        );
                      },
                    ),
                    Divider(
                      color: ThemeChanger.currentTheme.darkMode
                          ? ColorTheme.background
                          : ColorTheme.grey,
                    ),
                  ],
                ),
              )
              .toList(),
          context: context,
        );
      },
    );
  }
}
