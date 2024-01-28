import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../activity/slopes.dart';
import '../main.dart';

/// A utility class for fetching slope data from Overpass API.
class SlopeFetcher {
  /// Flag indicating whether data is currently being fetched.
  static bool currentlyFetching = false;

  /// Fetches slope and lift data based on the given latitude and longitude.
  ///
  /// @param latitude The latitude coordinate.
  /// @param longitude The longitude coordinate.
  /// @return A Future that completes when data fetching is done.
  static Future<void> fetchData(double latitude, double longitude) async {
    /// If data is currently being fetched, return.
    /// Only allow one fetch operation at a time.
    if (currentlyFetching) {
      return;
    }

    /// Set currentlyFetching to true to prevent multiple fetch operations.
    currentlyFetching = true;

    /// Make location inaccurate for privacy reasons (+- 100m)
    latitude = latitude + Random().nextDouble() * 0.001;
    longitude = longitude + Random().nextDouble() * 0.001;

    try {
      await _fetchSlopeDataHelper(latitude, longitude, 'way');
      await _fetchSlopeDataHelper(latitude, longitude, 'relation');
    } catch (e) {
      if (kDebugMode) {
        print('Error while trying to fetch slope data: $e');
      }
    }
    String tBar = '"aerialway"="t-bar"';
    String chairLift = '"aerialway"="chair_lift"';
    String gondola = '"aerialway"="gondola"';
    String platter = '"aerialway"="platter"';
    String dragLift = '"aerialway"="drag_lift"';

    List<String> liftTypes = [tBar, chairLift, gondola, platter, dragLift];

    for (String liftType in liftTypes) {
      try {
        await _fetchLiftDataHelper(latitude, longitude, 'way', liftType);
        await _fetchLiftDataHelper(latitude, longitude, 'relation', liftType);
      } catch (e) {
        if (kDebugMode) {
          print('Error while trying to fetch lift data: $e');
        }
      }
    }
    currentlyFetching = false;
  }

  /// Fetches lift data based on the given latitude, longitude, Overpass type, and value.
  ///
  /// @param latitude The latitude coordinate.
  /// @param longitude The longitude coordinate.
  /// @param type The Overpass type (way or relation).
  /// @param value The Overpass value to filter the query.
  /// @return A Future<bool> indicating the success of the fetch operation.
  static Future<bool> _fetchLiftDataHelper(
      double latitude, double longitude, String type, String value) async {
    const distance = 20000;

    if (PowderPilot.connectionStatus) {
      final String overpassQuery = '''
    [out:json];
    (
      $type
        (around:$distance, $latitude, $longitude)
        [$value];
    );
    out geom;
''';

      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: {'data': overpassQuery},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return await _parseData(data, lift: true);
      }
    }
    return false;
  }

  /// Fetches slope data based on the given latitude, longitude, Overpass type, and value.
  ///
  /// @param latitude The latitude coordinate.
  /// @param longitude The longitude coordinate.
  /// @param type The Overpass type (way or relation).
  /// @return A Future<bool> indicating the success of the fetch operation.
  static Future<bool> _fetchSlopeDataHelper(
      double latitude, double longitude, String type) async {
    const distance = 20000;

    if (PowderPilot.connectionStatus) {
      final String overpassQuery = '''
    [out:json];
    (
      $type
        (around:$distance, $latitude, $longitude)
        ["piste:type"];
    );
    out geom;
''';

      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: {'data': overpassQuery},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return await _parseData(data);
      }
    }
    return false;
  }

  /// Parses the fetched data and adds slope objects to the SlopeMap.
  /// The data is processed in batches to speed up the parsing process.
  ///
  /// @param data The map containing the fetched data.
  /// @param lift A flag indicating whether the fetched data is for a lift.
  /// @return A Future<bool> indicating the success of the parse operation.
  static Future<bool> _parseData(Map<String, dynamic> data, {bool lift = false}) async {
    /// Create a list to store futures of the parsing logic
    List<Future<void>> parsingFutures = [];

    for (final element in data['elements']) {
      /// Add each parsing operation to the list of futures
      parsingFutures.add(_parseElement(element, lift));
    }

    /// Wait for all parsing operations to complete
    await Future.wait(parsingFutures);

    return true;
  }

  /// Parses a single element and adds a slope object to the SlopeMap.
  ///
  /// @param element The element to parse.
  static Future<void> _parseElement(dynamic element, bool lift) async {
    try {
      /// Create a new slope object from the element
      Slope slope = Slope(slope: element, lift: lift);
      /// Add the slope object to the SlopeMap
      SlopeMap.addSlope(slope);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
