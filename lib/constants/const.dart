class AppConstants {
  // API Base URL
  static const String baseUrl = 'https://your-server-domain.com';

  // API Endpoints
  static const String connectEndpoint = '/connect';
  static const String pingEndpoint = '/ping';
  static const String disconnectEndpoint = '/disconnect';

  // Network Settings
  static const int connectionTimeout = 30; // seconds
  static const int pingInterval = 5; // seconds

  // Error Messages
  static const String connectionError = 'Failed to connect to server';
  static const String timeoutError = 'Connection timeout';
  static const String networkError = 'Network error occurred';
}
