/// Application Configuration
/// Provides environment-level switches for live REST endpoints vs in-memory mock repository.
class AppConfig {
  AppConfig._();

  static const String appName = 'Mahakhanij Consumer';
  static const String appVersion = '2.0.0';

  /// Toggle this to false when connecting to the live Government backend API
  static const bool useMockData = true;

  /// Base API URL for Maharashtra Minor Mineral portal backend
  static const String apiBaseUrl = 'https://api.mahakhanij.gov.in/api/v1';

  /// Simulated network latency (in milliseconds) for mock repository
  static const int mockLatencyMs = 350;
}
