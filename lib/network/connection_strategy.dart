// 통신 전략을 위한 인터페이스
abstract class ConnectionStrategy {
  void Function(String ip)? onIpReceived;
  Future<void> initialize();
  Future<void> connect(String ipAddress);
  Future<Map<String, dynamic>> getData();
  Future<void> sendPingResult(double responseTime, double latitude, double longitude);
  void dispose();

  String? getTarget();

  getPublicIpAddress() {}
}
