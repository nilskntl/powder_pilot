import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ski_tracker/main.dart';
import 'package:ski_tracker/slopes.dart';

class SlopeFetcher {
  static bool currentlyFetching = false;

  static Future<void> fetchData(double latitude, double longitude) async {
    if (currentlyFetching) {
      return;
    }
    currentlyFetching = true;
    try {
      await _fetchDataHelper(latitude, longitude, 'way');
      await _fetchDataHelper(latitude, longitude, 'relation');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    String tBar = '"aerialway"="t-bar"';
    String chairLift = '"aerialway"="chair_lift"';
    String gondola = '"aerialway"="gondola"';
    String platter = '"aerialway"="platter"';
    String dragLift = '"aerialway"="drag_lift"';

    try {
      await _fetchLiftDataHelper(latitude, longitude, 'way', tBar);
      await _fetchLiftDataHelper(latitude, longitude, 'relation', tBar);
      await _fetchLiftDataHelper(latitude, longitude, 'way', chairLift);
      await _fetchLiftDataHelper(latitude, longitude, 'relation', chairLift);
      await _fetchLiftDataHelper(latitude, longitude, 'way', gondola);
      await _fetchLiftDataHelper(latitude, longitude, 'relation', gondola);
      await _fetchLiftDataHelper(latitude, longitude, 'way', platter);
      await _fetchLiftDataHelper(latitude, longitude, 'relation', platter);
      await _fetchLiftDataHelper(latitude, longitude, 'way', dragLift);
      await _fetchLiftDataHelper(latitude, longitude, 'relation', dragLift);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    currentlyFetching = false;
  }

  static Future<bool> _fetchLiftDataHelper(
      double latitude, double longitude, String type, String value) async {
    const distance = 20000;

    if (SkiTracker.connectionStatus) {
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
        return await parseData(data, lift: true);
      }
    }
    return false;
  }

  static Future<bool> _fetchDataHelper(
      double latitude, double longitude, String type) async {
    const distance = 20000;

    if (SkiTracker.connectionStatus) {
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
        return await parseData(data);
      }
    }
    return false;
  }

  static Future<bool> parseData(Map<String, dynamic> data,
      {bool lift = false}) async {
    for (final element in data['elements']) {
      try {
        Slope slope = Slope(slope: element, lift: lift);
        SlopeMap.addSlope(slope);
      } catch (e) {
        print(e);
      }
    }
    return true;
  }
}
