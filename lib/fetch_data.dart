import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ski_tracker/main.dart';
import 'package:ski_tracker/slopes.dart';

class SlopeFetcher {
  static Future<bool> fetchData(double latitude, double longitude) async {
    bool way = await _fetchDataHelper(latitude, longitude, 'way');
    bool relation = await _fetchDataHelper(latitude, longitude, 'relation');
    return way && relation;
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
        return parseData(data);
      }
    }
    return false;
  }

  static bool parseData(Map<String, dynamic> data) {
    for (final element in data['elements']) {
      try {
        Slope slope = Slope(slope: element);
        SlopeMap.addSlope(slope);
      } catch (e) {
        return false;
      }
    }
    return true;
  }
}
