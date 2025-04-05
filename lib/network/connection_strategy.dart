// 통신 전략을 위한 인터페이스
abstract class ConnectionStrategy {
  Future<void> initialize();
  Future<void> connect(String ipAddress);
  Future<Map<String, dynamic>> getData();
  Future<void> sendPingResult(double responseTime, Map<String, double> gpsData);
  void dispose();

  getPublicIpAddress() {}
}
