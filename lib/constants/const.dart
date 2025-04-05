class AppConstants {
  // API Base URL
  static const String baseUrl = 'http://192.168.233.233:8081';

  // API Endpoints
  static const String connectEndpoint = '/connect';
  static const String pingEndpoint = '/ping';
  static const String pollingEndpoint = '/poll';

  static const String disconnectEndpoint = '/disconnect';

  // Network Settings
  static const int connectionTimeout = 30; // seconds
  static const int pingInterval = 1000; // seconds

  // Error Messages
  static const String connectionError = 'Failed to connect to server';
  static const String timeoutError = 'Connection timeout';
  static const String networkError = 'Network error occurred';
}
