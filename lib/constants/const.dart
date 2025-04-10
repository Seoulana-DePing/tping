class AppConstants {
  // API Base URL
  static const String baseUrl = 'http://192.168.233.117:1112';

  // API Endpoints
  static const String healthCheckEndpoint = '/health-check';
  static const String resultEndpoint = '/result';
  static const String pollingEndpoint = '/polling';
  static const String walletAddress = "#sadf123uilkxcvjkl";

  static const String disconnectEndpoint = '/disconnect';

  // Network Settings
  static const int connectionTimeout = 30; // seconds
  static const int pingInterval = 2000; // seconds

  // Error Messages
  static const String connectionError = 'Failed to connect to server';
  static const String timeoutError = 'Connection timeout';
  static const String networkError = 'Network error occurred';
}
