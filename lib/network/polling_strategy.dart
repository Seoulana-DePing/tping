import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'connection_strategy.dart';

class PollingStrategy implements ConnectionStrategy {
  final String baseUrl;
  final String baseEndpoint;
  final String pollingEndpoint;
  final int pollingInterval;

  Timer? _timer;
  String? _connectedIpAddress;
  String? _targetIp;

  PollingStrategy({
    required this.baseUrl,
    required this.baseEndpoint, // 기본값 1초
    required this.pollingEndpoint, // 기본값 1초
    this.pollingInterval = 1000,
  });

  @override
  void Function(String ip)? onIpReceived;

  @override
  Future<void> initialize() async {
    // 초기화 로직
  }

  @override
  String? getTarget() {
    return _targetIp;
  }

  @override
  Future<void> connect(String ipAddress) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$baseEndpoint'),
        headers: {'Content-Type': 'application/json'},
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
    _timer = Timer.periodic(Duration(milliseconds: pollingInterval), (_) async {
      final response = await getData();
      _targetIp = response['ip'];
      if (_targetIp != null) {
        onIpReceived?.call(_targetIp!); // IP를 받았을 때 callback 실행
      }
    });
  }

  @override
  Future<Map<String, dynamic>> getData() async {
    try {
      if (_connectedIpAddress == null) {
        throw PollingException('Not connected');
      }

      final response = await http.get(
        Uri.parse('$baseUrl$pollingEndpoint'),
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
