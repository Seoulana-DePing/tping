// mock_server.dart
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final app = Router();

  app.get('/health-check', (Request request) {
    return Response.ok('');
  });

  app.post('/result', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final latitude = data['latitude'];
    final longitude = data['longitude'];
    final response_time = data['response_time'];
    final walletAddress = data['wallet_address'];

    print('응답시간: ${response_time}, 지갑: ${walletAddress}');
    print('위도: ${latitude}, 경도: ${longitude}');
    return Response.ok('');
  });

  app.get('/polling', (Request request) async {
    return Response.ok(
      '{"ip": "8.8.8.8"}',
      headers: {'Content-Type': 'application/json'},
    );
  });

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8081);
  print(
    '✅ Mock server listening at http://${server.address.host}:${server.port}',
  );
}
