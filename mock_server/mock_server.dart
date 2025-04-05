// mock_server.dart
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final app = Router();

  app.get('/ping', (Request request) {
    return Response.ok(
      '{"id":1, "name":"Mock User"}',
      headers: {'Content-Type': 'application/json'},
    );
  });

  app.post('/ping-result', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final longitude = data['longitude'];  // bo
    print(longitude);
    return Response.ok(
      '{"id":1, "name":"Mock User"}',
      headers: {'Content-Type': 'application/json'},
    );
  });

  app.get('/poll', (Request request) async {
    return Response.ok(
      '{"ip": "8.8.8.8"}',
      headers: {'Content-Type': 'application/json'},
    );
  });

  app.get('/api/ip', (Request request) async {
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
