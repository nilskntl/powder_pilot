import 'package:intl/intl.dart';

import 'main.dart';

/// Class to define String constants used in the app.
class StringPool {
  static String get APP_NAME => PowderPilot.appName;

  static String get IDLE => Intl.message('Idle',
      name: 'StringPool_IDLE', locale: PowderPilot.language[0]);

  static String get RUNNING => Intl.message('Running',
      name: 'StringPool_RUNNING', locale: PowderPilot.language[0]);

  static String get PAUSED => Intl.message('Paused',
      name: 'StringPool_PAUSED', locale: PowderPilot.language[0]);

  static String get FINISHED => Intl.message('Finished',
      name: 'StringPool_FINISHED', locale: PowderPilot.language[0]);

  static String get INACTIVE => Intl.message('Inactive',
      name: 'StringPool_INACTIVE', locale: PowderPilot.language[0]);

  static String get SPEED => Intl.message('Speed',
      name: 'StringPool_SPEED', locale: PowderPilot.language[0]);

  static String get ALTITUDE => Intl.message('Altitude',
      name: 'StringPool_ALTITUDE', locale: PowderPilot.language[0]);

  static String get DOWNWARD_SLOPE => Intl.message('Slope',
      name: 'StringPool_DOWNWARD_SLOPE', locale: PowderPilot.language[0]);

  static String get DISTANCE => Intl.message('Distance',
      name: 'StringPool_DISTANCE', locale: PowderPilot.language[0]);

  static String get DURATION => Intl.message('Duration',
      name: 'StringPool_DURATION', locale: PowderPilot.language[0]);

  static String get TOTAL => Intl.message('Total',
      name: 'StringPool_TOTAL', locale: PowderPilot.language[0]);

  static String get RUNS => Intl.message('Runs',
      name: 'StringPool_RUNS', locale: PowderPilot.language[0]);

  static String get TIME => Intl.message('Time',
      name: 'StringPool_TIME', locale: PowderPilot.language[0]);

  static String get DOWNHILL =>
      Intl.message('Downhill', name: 'StringPool_DOWNHILL');

  static String get UPHILL => Intl.message('Uphill',
      name: 'StringPool_UPHILL', locale: PowderPilot.language[0]);

  static String get PAUSE => Intl.message('Pause',
      name: 'StringPool_PAUSE', locale: PowderPilot.language[0]);

  static String get RESUME => Intl.message('Resume',
      name: 'StringPool_RESUME', locale: PowderPilot.language[0]);

  static String get START => Intl.message('Start',
      name: 'StringPool_START', locale: PowderPilot.language[0]);

  static String get STOP => Intl.message('Stop',
      name: 'StringPool_STOP', locale: PowderPilot.language[0]);

  static String get CURRENT =>
      Intl.message('Current', name: 'StringPool_CURRENT');

  static String get AVERAGE => Intl.message('Avg',
      name: 'StringPool_AVERAGE', locale: PowderPilot.language[0]);

  static String get MAX => Intl.message('Max',
      name: 'StringPool_MAX', locale: PowderPilot.language[0]);

  static String get MIN => Intl.message('Min',
      name: 'StringPool_MIN', locale: PowderPilot.language[0]);

  static String get LONGEST => Intl.message('Longest',
      name: 'StringPool_LONGEST', locale: PowderPilot.language[0]);

  static String get ACTIVITY => Intl.message('Activity',
      name: 'StringPool_ACTIVITY', locale: PowderPilot.language[0]);

  static String get HISTORY => Intl.message('History',
      name: 'StringPool_HISTORY', locale: PowderPilot.language[0]);

  static String get NO_ACTIVITIES => Intl.message('No activities found.',
      name: 'StringPool_NO_ACTIVITIES', locale: PowderPilot.language[0]);

  static String get ACTIVITIES =>
      Intl.message('Activities', name: 'StringPool_ACTIVITIES');

  static String get LATEST => Intl.message('Latest',
      name: 'StringPool_LATEST', locale: PowderPilot.language[0]);

  static String get EARLIEST =>
      Intl.message('Earliest', name: 'StringPool_EARLIEST');

  static String get DELETE => Intl.message('Delete',
      name: 'StringPool_DELETE', locale: PowderPilot.language[0]);

  static String get DELETE_ACTIVITY => Intl.message('Delete activity?',
      name: 'StringPool_DELETE_ACTIVITY', locale: PowderPilot.language[0]);

  static String get DELETE_ACTIVITY_CONFIRMATION =>
      Intl.message('Are you sure you want to delete this activity?',
          name: 'StringPool_DELETE_ACTIVITY_CONFIRMATION',
          locale: PowderPilot.language[0]);

  static String get CANCEL => Intl.message('Cancel',
      name: 'StringPool_CANCEL', locale: PowderPilot.language[0]);

  static String get SUMMARY => Intl.message('Summary',
      name: 'StringPool_SUMMARY', locale: PowderPilot.language[0]);

  static String get SETTINGS => Intl.message('Settings',
      name: 'StringPool_SETTINGS', locale: PowderPilot.language[0]);

  static String get MEASUREMENT => Intl.message('Measurement',
      name: 'StringPool_MEASUREMENT', locale: PowderPilot.language[0]);

  static String get LANGUAGE => Intl.message('Language',
      name: 'StringPool_LANGUAGE', locale: PowderPilot.language[0]);

  static String get APP_THEME => Intl.message('App Theme',
      name: 'StringPool_APP_THEME', locale: PowderPilot.language[0]);

  static String get CHANGE_APP_THEME => Intl.message('Change the app theme',
      name: 'StringPool_CHANGE_APP_THEME', locale: PowderPilot.language[0]);

  static String get LIGHT_THEME => Intl.message('Light',
      name: 'StringPool_LIGHT_THEME', locale: PowderPilot.language[0]);

  static String get DARK_THEME => Intl.message('Dark',
      name: 'StringPool_DARK_THEME', locale: PowderPilot.language[0]);

  static String get CURRENT_MEASUREMENT => Intl.message('Current system: ',
      name: 'StringPool_CURRENT_MEASUREMENT', locale: PowderPilot.language[0]);

  static String get MEASUREMENT_METRIC => Intl.message('Metric',
      name: 'StringPool_MEASUREMENT_METRIC', locale: PowderPilot.language[0]);

  static String get MEASUREMENT_IMPERIAL => Intl.message('Imperial',
      name: 'StringPool_MEASUREMENT_IMPERIAL', locale: PowderPilot.language[0]);

  static String get UNKNOWN_AREA => Intl.message('Unknown',
      name: 'StringPool_UNKNOWN_AREA', locale: PowderPilot.language[0]);

  static String get FREE_RIDE => Intl.message('Free Ride',
      name: 'StringPool_FREE_RIDE', locale: PowderPilot.language[0]);

  static String get SLOPE_PISTE => Intl.message('Slope',
      name: 'StringPool_SLOPE_PISTE', locale: PowderPilot.language[0]);

  static String get NOTIFICATION_TEXT => Intl.message(
      'Your ski journey is being tracked in the background. Enjoy the ride!',
      name: 'StringPool_NOTIFICATION_TEXT',
      locale: PowderPilot.language[0]);

  static String get NOTIFICATION_TITLE => Intl.message('Activity in progress',
      name: 'StringPool_NOTIFICATION_TITLE', locale: PowderPilot.language[0]);

  static String get BUTTON_TEXT => Intl.message('Next',
      name: 'StringPool_BUTTON_TEXT', locale: PowderPilot.language[0]);

  static String get OPEN_SETTINGS => Intl.message('Open Settings',
      name: 'StringPool_OPEN_SETTINGS', locale: PowderPilot.language[0]);

  static String get ENABLE_LOCATION => Intl.message('Enable Location',
      name: 'StringPool_ENABLE_LOCATION', locale: PowderPilot.language[0]);

  static String get GET_STARTED => Intl.message('Get started',
      name: 'StringPool_GET_STARTED', locale: PowderPilot.language[0]);

  static String get WELCOME_TITLE =>
      '${Intl.message('Welcome to', name: 'StringPool_WELCOME_TITLE', locale: PowderPilot.language[0])} ${PowderPilot.appName}';

  static String get WELCOME_SUBTITLE_1 =>
      '${Intl.message('Track your skiing activity with', name: 'StringPool_WELCOME_SUBTITLE_1', locale: PowderPilot.language[0])} ${PowderPilot.appName}.';

  static String get WELCOME_SUBTITLE_2 =>
      Intl.message('See your stats and improve your skiing.',
          name: 'StringPool_WELCOME_SUBTITLE_2',
          locale: PowderPilot.language[0]);

  static String get WELCOME_SUBTITLE_3 => Intl.message('Analyse your ski day.',
      name: 'StringPool_WELCOME_SUBTITLE_3', locale: PowderPilot.language[0]);

  static String get LOCATION_ACCESS_TITLE => Intl.message('Location Access',
      name: 'StringPool_LOCATION_ACCESS_TITLE',
      locale: PowderPilot.language[0]);

  static String get LOCATION_ACCESS_SUBTITLE => Intl.message(
      'To track your activity Powder Pilot needs access to your GPS location.',
      name: 'StringPool_LOCATION_ACCESS_SUBTITLE',
      locale: PowderPilot.language[0]);

  static String get BATTERY_OPTIMIZATION_TITLE =>
      Intl.message('Background Mode',
          name: 'StringPool_BATTERY_OPTIMIZATION_TITLE',
          locale: PowderPilot.language[0]);

  static String get BATTERY_OPTIMIZATION_SUBTITLE => Intl.message(
      'Enable background mode of your device to allow proper work of Powder Pilot when the screen is switched off.',
      name: 'StringPool_BATTERY_OPTIMIZATION_SUBTITLE',
      locale: PowderPilot.language[0]);

  static String get LAST_TITLE => Intl.message('Last steps to go',
      name: 'StringPool_LAST_TITLE', locale: PowderPilot.language[0]);

  static String get LAST_SUBTITLE =>
      Intl.message('Finish your setup and start tracking your activity.',
          name: 'StringPool_LAST_SUBTITLE', locale: PowderPilot.language[0]);

  static String get TERMS_OF_SERVICE => Intl.message('Terms of Service',
      name: 'StringPool_TERMS_OF_SERVICE', locale: PowderPilot.language[0]);

  static String get PRIVACY_POLICY => Intl.message('Privacy Policy',
      name: 'StringPool_PRIVACY_POLICY', locale: PowderPilot.language[0]);

  static String get LEGAL_TEXT_1 => Intl.message('I agree to the ',
      name: 'StringPool_LEGAL_TEXT_1', locale: PowderPilot.language[0]);

  static String get LEGAL_TEXT_2 => Intl.message(' and the ',
      name: 'StringPool_LEGAL_TEXT_2', locale: PowderPilot.language[0]);

  static String get LEGAL_TEXT_3 => Intl.message('.',
      name: 'StringPool_LEGAL_TEXT_3', locale: PowderPilot.language[0]);

  static List<String> get LEGAL_TEXT =>
      [LEGAL_TEXT_1, TERMS_OF_SERVICE, LEGAL_TEXT_2, PRIVACY_POLICY, LEGAL_TEXT_3];
}
