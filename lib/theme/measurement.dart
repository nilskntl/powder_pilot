class Measurement {
  static String unitSpeed = 'km/h';
  static String unitDistance = 'km';
  static String unitAltitude = 'm';
  static String unitSlope = '%';
  static String unitTime = 'h';

  static double speedFactor = 3.6;
  static double distanceFactor = 1;
  static double altitudeFactor = 1;

  static void setUnits(String units) {
    if (units == 'imperial') {
      unitSpeed = 'mph';
      unitDistance = 'mi';
      unitAltitude = 'ft';
      speedFactor = 2.236936;
      distanceFactor = 0.621371;
      altitudeFactor = 3.28084;
    } else {
      unitSpeed = 'km/h';
      unitDistance = 'km';
      unitAltitude = 'm';
      speedFactor = 3.6;
      distanceFactor = 1;
      altitudeFactor = 1;
    }
  }
}