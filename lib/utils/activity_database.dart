import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ActivityDatabaseHelper {

  // This is the actual database filename that is saved in the docs directory.
  static const _databaseName = "activity_databasen.db";
  // Table name
  static const _tableName = "activity";
  // Increment this version when you need to change the schema.
  static const _databaseVersion = 1;

  // Make this a singleton class.
  ActivityDatabaseHelper._privateConstructor();
  static final ActivityDatabaseHelper instance = ActivityDatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static late Database _database;
  static bool _initialized = false;

  static Future<Database> _initDatabase() async {
    // Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required.
    WidgetsFlutterBinding.ensureInitialized();
    // Open the database and store the reference.
    Database db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), _databaseName),
      // When the database is first created, create a table to store activitys.
      version: _databaseVersion,
      onCreate: (db, version) {
        _onCreate(db, version);
      },
    );
    _initialized = true;
    return db;
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE activity(
                id INTEGER PRIMARY KEY,
                areaName TEXT,
                maxSpeed REAL,
                averageSpeed REAL,
                totalRuns INTEGER,
                longestRun REAL,
                maxAltitude REAL,
                minAltitude REAL,
                avgAltitude REAL,
                maxSlope REAL,
                avgSlope REAL,
                distance REAL,
                distanceDownhill REAL,
                distanceUphill REAL,
                elapsedTime TEXT,
                elapsedDownhillTime TEXT,
                elapsedUphillTime TEXT,
                elapsedPauseTime TEXT,
                route TEXT,
                startTime TEXT,
                endTime TEXT,
                altitudes TEXT,
                speeds TEXT
              )
              ''');
  }

  static Future<Database> get database async {
    if (_initialized) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // Define a function that inserts activities into the database
  static Future<void> insertActivity(ActivityDatabase activityDatabase) async {
    // Get a reference to the database.
    Database db = await database;

    // Check if the id is -1, if so, generate a new unique id.
    if (activityDatabase.id == -1) {
      // Query the maximum existing id in the database.
      List<Map<String, dynamic>> result =
      await db.rawQuery('SELECT MAX(id) as maxId FROM $_tableName');
      int maxId = (result.first['maxId'] ?? 0) as int;

      // Generate a new unique id.
      activityDatabase = activityDatabase.copyWith(newId: maxId + 1);
    }

    // Insert the Activity
    await db.insert(
      _tableName,
      activityDatabase.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the activities from the activity table.
  static Future<List<ActivityDatabase>> activities() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Activities.
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    // Convert the List<Map<String, dynamic> into a List<Activity>.
    return List.generate(maps.length, (i) {
      return ActivityDatabase(
        id: maps[i]['id'] as int,
        areaName: maps[i]['areaName'] as String,
        maxSpeed: maps[i]['maxSpeed'] as double,
        averageSpeed: maps[i]['averageSpeed'] as double,
        totalRuns: maps[i]['totalRuns'] as int,
        longestRun: maps[i]['longestRun'] as double,
        maxAltitude: maps[i]['maxAltitude'] as double,
        minAltitude: maps[i]['minAltitude'] as double,
        avgAltitude: maps[i]['avgAltitude'] as double,
        maxSlope: maps[i]['maxSlope'] as double,
        avgSlope: maps[i]['avgSlope'] as double,
        distance: maps[i]['distance'] as double,
        distanceDownhill: maps[i]['distanceDownhill'] as double,
        distanceUphill: maps[i]['distanceUphill'] as double,
        elapsedTime: maps[i]['elapsedTime'] as String,
        elapsedDownhillTime: maps[i]['elapsedDownhillTime'] as String,
        elapsedUphillTime: maps[i]['elapsedUphillTime'] as String,
        elapsedPauseTime: maps[i]['elapsedPauseTime'] as String,
        route: maps[i]['route'] as String,
        startTime: maps[i]['startTime'] as String,
        endTime: maps[i]['endTime'] as String,
        altitudes: maps[i]['altitudes'] as String,
        speeds: maps[i]['speeds'] as String,
      );
    });

  }

  static Future<void> updateActivity(ActivityDatabase activityDatabase) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Activity,
    await db.update(
      _tableName,
      activityDatabase.toMap(),
      // Ensure that the Activity has a matching id.
      where: 'id = ?',
      // Pass the Activity's id as a whereArg to prevent SQL injection.
      whereArgs: [activityDatabase.id],
    );
  }

  static Future<void> deleteActivity(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Activity from the database.
    await db.delete(
      _tableName,
      // Use a `where` clause to delete a specific Activity.
      where: 'id = ?',
      // Pass the Activity's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  static deleteDatabase() async {
    final db = await database;
    await db.delete(_tableName);
  }
}

class ActivityDatabase {
  // Unique ID
  final int id;

  // Area
  final String areaName;

  // Speed
  final double maxSpeed;
  final double averageSpeed;

  // Runs
  final int totalRuns;
  final double longestRun;

  // Altitude
  final double maxAltitude;
  final double minAltitude;
  final double avgAltitude;

  // Slope
  final double maxSlope;
  final double avgSlope;

  // Distance
  final double distance;
  final double distanceDownhill;
  final double distanceUphill;

  // Duration
  final String elapsedTime;
  final String elapsedDownhillTime;
  final String elapsedUphillTime;
  final String elapsedPauseTime;

  // Route
  final String route;

  // Start time
  final String startTime;
  final String endTime;

  // List of altitudes
  final String altitudes;

  // List of speeds
  final String speeds;

  const ActivityDatabase(
      {required this.areaName,
      required this.maxSpeed,
      required this.averageSpeed,
      required this.totalRuns,
      required this.longestRun,
      required this.maxAltitude,
      required this.minAltitude,
      required this.avgAltitude,
      required this.maxSlope,
      required this.avgSlope,
      required this.distance,
      required this.distanceDownhill,
      required this.distanceUphill,
      required this.elapsedTime,
      required this.elapsedDownhillTime,
      required this.elapsedUphillTime,
      required this.elapsedPauseTime,
      required this.route, required this.startTime, required this.endTime, this.id=-1, required this.altitudes, required this.speeds});

  // Convert a Activity into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'areaName': areaName,
      'maxSpeed': maxSpeed,
      'averageSpeed': averageSpeed,
      'totalRuns': totalRuns,
      'longestRun': longestRun,
      'maxAltitude': maxAltitude,
      'minAltitude': minAltitude,
      'avgAltitude': avgAltitude,
      'maxSlope': maxSlope,
      'avgSlope': avgSlope,
      'distance': distance,
      'distanceDownhill': distanceDownhill,
      'distanceUphill': distanceUphill,
      'elapsedTime': elapsedTime,
      'elapsedDownhillTime': elapsedDownhillTime,
      'elapsedUphillTime': elapsedUphillTime,
      'elapsedPauseTime': elapsedPauseTime,
      'route': route,
      'startTime': startTime,
      'endTime': endTime,
      'altitudes': altitudes,
      'speeds': speeds,
    };
  }

  // Implement toString to make it easier to see information about
  // each Activity when using the print statement.
  @override
  String toString() {
    return 'Activity{id: $id, areaName: $areaName, maxSpeed: $maxSpeed, averageSpeed: $averageSpeed, totalRuns: $totalRuns, longestRun: $longestRun, maxAltitude: $maxAltitude, minAltitude: $minAltitude, avgAltitude: $avgAltitude, maxSlope: $maxSlope, avgSlope: $avgSlope, distance: $distance, distanceDownhill: $distanceDownhill, distanceUphill: $distanceUphill, elapsedTime: $elapsedTime, elapsedDownhillTime: $elapsedDownhillTime, elapsedUphillTime: $elapsedUphillTime, elapsedPauseTime: $elapsedPauseTime, route: $route, startTime: $startTime, endTime: $endTime, altitudes: $altitudes}';
  }

  ActivityDatabase copyWith({required int newId}) {
    return ActivityDatabase(
      id: newId,
      areaName: areaName,
      maxSpeed: maxSpeed,
      averageSpeed: averageSpeed,
      totalRuns: totalRuns,
      longestRun: longestRun,
      maxAltitude: maxAltitude,
      minAltitude: minAltitude,
      avgAltitude: avgAltitude,
      maxSlope: maxSlope,
      avgSlope: avgSlope,
      distance: distance,
      distanceDownhill: distanceDownhill,
      distanceUphill: distanceUphill,
      elapsedTime: elapsedTime,
      elapsedDownhillTime: elapsedDownhillTime,
      elapsedUphillTime: elapsedUphillTime,
      elapsedPauseTime: elapsedPauseTime,
      route: route,
      startTime: startTime,
      endTime: endTime,
      altitudes: altitudes,
      speeds: speeds,
    );
  }
}
