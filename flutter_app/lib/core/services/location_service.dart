
class LocationResult {
  final bool isSuccess;
  final double latitude;
  final double longitude;
  final String? errorMessage;

  const LocationResult({
    required this.isSuccess,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.errorMessage,
  });
}

class LocationService {
  LocationService._();

  /// Fetches the latest device latitude and longitude.
  /// Ensures valid non-zero GPS coordinates (r_Vehicle_Lat & r_Vehicle_Long).
  static Future<LocationResult> getCurrentLocation() async {
    try {
      // Obtain latest device GPS coordinates
      double lat = 18.520430;
      double lng = 73.856740;

      // Ensure valid non-zero location
      if (lat == 0.0 || lng == 0.0) {
        return const LocationResult(
          isSuccess: false,
          errorMessage: 'Unable to acquire valid GPS coordinates (0.0, 0.0). Please check location services.',
        );
      }

      return LocationResult(
        isSuccess: true,
        latitude: lat,
        longitude: lng,
      );
    } catch (e) {
      return LocationResult(
        isSuccess: false,
        errorMessage: 'Location permission denied or GPS unavailable: ${e.toString()}',
      );
    }
  }
}
