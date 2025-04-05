import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'connection_strategy.dart';

class PollingStrategy implements ConnectionStrategy {
  final String baseUrl;
  final int pollingInterval;
  Timer? _timer;
  String? _connectedIpAddress;

  PollingStrategy({
    required this.baseUrl,
    this.pollingInterval = 1000, // 기본값 1초
  });

  @override
  Future<void> initialize() async {
    // 초기화 로직
  }

  @override
  Future<void> connect(String ipAddress) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/connect'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ip_address': ipAddress}),
      );

      if (response.statusCode != 200) {
        throw PollingException('Connection failed: ${response.statusCode}');
      }

      _connectedIpAddress = ipAddress;
      _startPolling();
    } catch (e) {
      throw PollingException('Failed to connect: $e');
    }
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: pollingInterval),
      (_) => getData(),
    );
  }

  @override
  Future<Map<String, dynamic>> getData() async {
    try {
      if (_connectedIpAddress == null) {
        throw PollingException('Not connected');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/data'),
        headers: {
          'Content-Type': 'application/json',
          'X-Client-IP': _connectedIpAddress!,
        },
      );

      if (response.statusCode != 200) {
        throw PollingException('Failed to get data: ${response.statusCode}');
      }

      return json.decode(response.body);
    } catch (e) {
      throw PollingException('Failed to get data: $e');
    }
  }

  @override
  Future<void> sendPingResult(
    double responseTime,
    Map<String, double> gpsData,
  ) async {
    try {
      if (_connectedIpAddress == null) {
        throw PollingException('Not connected');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/ping-result'),
        headers: {
          'Content-Type': 'application/json',
          'X-Client-IP': _connectedIpAddress!,
        },
        body: json.encode({
          'response_time': responseTime,
          'latitude': gpsData['latitude'],
          'longitude': gpsData['longitude'],
        }),
      );

      if (response.statusCode != 200) {
        throw PollingException(
          'Failed to send ping result: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw PollingException('Failed to send ping result: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _connectedIpAddress = null;
  }

  @override
  Future<String> getPublicIpAddress() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/public-ip'));
      if (response.statusCode != 200) {
        throw PollingException(
          'Failed to get public IP: ${response.statusCode}',
        );
      }
      return json.decode(response.body)['ip'];
    } catch (e) {
      throw PollingException('Failed to get public IP: $e');
    }
  }
}

class PollingException implements Exception {
  final String message;
  PollingException(this.message);

  @override
  String toString() => 'PollingException: $message';
}
