import 'package:dart_ipify/dart_ipify.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:t_ping/network/connection_strategy.dart';
import 'package:t_ping/services/location_service.dart';
import 'dart:math';

class NetworkService {
  static const int MAX_RETRIES = 3;

  late ConnectionStrategy _strategy;
  final LocationService _locationService;

  NetworkService({
    required ConnectionStrategy strategy,
    required LocationService locationService,
  }) : _strategy = strategy,
       _locationService = locationService;

  Future<T> _withRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (attempts < MAX_RETRIES) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts == MAX_RETRIES) rethrow;

        // 지수 백오프로 재시도 간격 증가
        final waitTime = Duration(
          milliseconds: pow(2, attempts).toInt() * 1000,
        );
        await Future.delayed(waitTime);
      }
    }
    throw NetworkException('Max retry attempts reached');
  }

  void setStrategy(ConnectionStrategy strategy) {
    _strategy.dispose();
    _strategy = strategy;
    _strategy.initialize();
  }

  Future<void> startConnection() async {
    final ipAddress = await _getIpAddress();
    await _strategy.connect(ipAddress);
  }

  Future<void> handlePing() async {
    try {
      final data = await _strategy.getData();
      final ipToPing = data['ip_address'];

      // Ping 수행
      final ping = Ping(ipToPing, count: 1);
      double? responseTime;

      await for (final response in ping.stream) {
        if (response.response != null) {
          responseTime = response.response!.time!.inMilliseconds.toDouble();
          break;
        }
      }

      if (responseTime == null) {
        throw NetworkException('Failed to get ping response');
      }

      final position = await _locationService.getCurrentLocation();

      await _strategy.sendPingResult(responseTime, {
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    } catch (e) {
      throw NetworkException('Ping operation failed: $e');
    }
  }

  Future<String> _getIpAddress() async {
    try {
      final ipv4 = await Ipify.ipv4();
      return ipv4;
    } catch (e) {
      throw NetworkException('Failed to get IP address: $e');
    }
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
