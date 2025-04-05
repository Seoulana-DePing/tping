import 'dart:convert';
import 'package:t_ping/network/connection_strategy.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketStrategy implements ConnectionStrategy {
  final String wsUrl;
  WebSocketChannel? _channel;

  WebSocketStrategy({required this.wsUrl});

  @override
  Future<void> initialize() async {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
  }

  @override
  Future<void> connect(String ipAddress) async {
    _channel?.sink.add(
      json.encode({'type': 'connect', 'ip_address': ipAddress}),
    );
  }

  @override
  Future<Map<String, dynamic>> getData() async {
    if (_channel == null) throw StateError('WebSocket channel not initialized');
    // WebSocket 스트림에서 데이터 수신
    return json.decode(await _channel!.stream.first);
  }

  @override
  Future<void> sendPingResult(
    double responseTime,
    Map<String, double> gpsData,
  ) async {
    _channel?.sink.add(
      json.encode({
        'type': 'ping_result',
        'response_time': responseTime,
        'gps_data': gpsData,
      }),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
  }

  @override
  getPublicIpAddress() {
    // TODO: implement getPublicIpAddress
    throw UnimplementedError();
  }
}
