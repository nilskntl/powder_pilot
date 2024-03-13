import '../activity/database.dart';
import '../string_pool.dart';

/// This class is used to store the past activities of the user.
class PastActivities {
  /// The list of activities
  List<ActivityDatabase> activities = [];

  /// The list of all visited areas
  final Map<String, int> _areas = {};

  /// Flag to track if the activities are already loaded
  bool _loaded = false;

  /// Load the activities from the database.
  void loadActivities() async {
    activities = await ActivityDatabaseHelper.activities();

    /// Sort activities based on startTime in descending order
    activities.sort((a, b) => b.startTime.compareTo(a.startTime));

    /// Add the areas to the list of areas
    for (ActivityDatabase activity in activities) {
      _addAreaName(activity.areaName);
    }

    /// Set the flag to indicate that the activities are loaded
    _loaded = true;
  }

  /// Add the area name to the list of areas
  ///
  /// @param areaName The name of the area to be added
  void _addAreaName(String areaName) {
    if (areaName != '' &&
        areaName != 'Unknown' &&
        areaName != StringPool.UNKNOWN_AREA) {
      List<String> areaNameSplit = areaName.split(', ');
      areaName = areaNameSplit[0];
      if(areaNameSplit.length > 1) {
        areaName += '\n${areaNameSplit[1]}';
      }
      if (_areas.containsKey(areaName)) {
        _areas[areaName] = _areas[areaName]! + 1;
      } else {
        _areas[areaName] = 1;
      }
    }
  }

  /// Remove the area name from the list of areas
  ///
  /// @param areaName The name of the area to be removed
  void _removeAreaName(String areaName) {
    if (areaName != '' &&
        areaName != 'Unknown' &&
        areaName != StringPool.UNKNOWN_AREA) {
      if (_areas.containsKey(areaName)) {
        if (_areas[areaName] == 1) {
          _areas.remove(areaName);
        } else {
          _areas[areaName] = _areas[areaName]! - 1;
        }
      }
    }
  }

  /// Check if the list of activities contains a specific activity.
  ///
  /// @param id The id of the activity to check for
  bool containsActivity(int id) {
    return activities.any((element) => element.id == id);
  }

  /// Remove an activity from the list of activities.
  ///
  /// @param activity The id of the activity to be removed
  void removeActivity(int id) {
    /// Remove one from the area count
    _removeAreaName(
        activities.firstWhere((element) => element.id == id).areaName);

    /// Remove the activity from the list of activities
    activities.removeWhere((element) => element.id == id);

    /// Remove from the database
    ActivityDatabaseHelper.deleteActivity(id);
  }

  /// Returns the most 5 visited areas
  Map<String, int> mostVisitedAreas() {
    Map<String, int> sortedAreas = {};
    _areas.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value))
      ..take(5)
      ..forEach((e) {
        sortedAreas[e.key] = e.value;
      });
    return sortedAreas;
  }

  /// Add an activity to the list of activities.
  ///
  /// @param activity The activity to be added
  void addActivity(ActivityDatabase activity) {
    /// Add the activity as the new first element of the list
    activities.insert(0, activity);

    /// Add the area name to the list of areas
    _addAreaName(activity.areaName);

    /// Add to the database
    ActivityDatabaseHelper.insertActivity(activity);
  }

  /// Getter
  bool get isLoaded => _loaded;

  int get numActivities => activities.length;
}
