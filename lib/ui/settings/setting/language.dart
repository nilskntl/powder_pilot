import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:powder_pilot/main.dart';
import 'package:powder_pilot/ui/settings/settings.dart';

import '../../../l10n/messages_all_locales.dart';
import '../../../string_pool.dart';
import '../../../theme.dart';
import '../../../utils/general_utils.dart';
import '../../activity/activity_page.dart';

class LanguageSetting extends StatefulWidget {
  const LanguageSetting({super.key});

  @override
  State<LanguageSetting> createState() => _LanguageSettingState();
}

class _LanguageSettingState extends State<LanguageSetting> {
  void _switchLanguage(String language) async {
    if (kDebugMode) {
      print('Switching language to $language');
    }
    Intl.defaultLocale = language;
    PowderPilot.setLanguage(language);
    await initializeMessages(language);
    SettingsPage.reload();
    PowderPilot.reload();
    ActivityPage.reload();
    setState(() {});
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
                .map((language) => WidgetTheme.settingsOption(
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
                      _switchLanguage(language[0]);
                    }))
                .toList(),
            context: context);
      },
    );
  }
}
