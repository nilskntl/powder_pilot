import '../activity/database.dart';

/// This class is used to store the past activities of the user.
class PastActivities {
  List<ActivityDatabase> activities = [];

  /// Flag to track if the activities are already loaded
  bool _loaded = false;

  /// Load the activities from the database.
  void loadActivities() async {
    activities = await ActivityDatabaseHelper.activities();

    /// Sort activities based on startTime in descending order
    activities.sort((a, b) => b.startTime.compareTo(a.startTime));

    /// Set the flag to indicate that the activities are loaded
    _loaded = true;
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
    /// Remove the activity from the list of activities
    activities.removeWhere((element) => element.id == id);

    /// Remove from the database
    ActivityDatabaseHelper.deleteActivity(id);
  }

  /// Add an activity to the list of activities.
  ///
  /// @param activity The activity to be added
  void addActivity(ActivityDatabase activity) {
    /// Add the activity as the new first element of the list
    activities.insert(0, activity);
    /// Add to the database
    ActivityDatabaseHelper.insertActivity(activity);
  }

  /// Getter
  bool get isLoaded => _loaded;

  int get numActivities => activities.length;
}
