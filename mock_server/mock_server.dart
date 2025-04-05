// mock_server.dart
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final app = Router();

  app.get('/api/user', (Request request) {
    return Response.ok(
      '{"id":1, "name":"Mock User"}',
      headers: {'Content-Type': 'application/json'},
    );
  });

  app.post('/api/login', (Request request) async {
    final body = await request.readAsString();
    print('📥 로그인 요청: $body');
    return Response.ok(
      '{"token": "mock_token"}',
      headers: {'Content-Type': 'application/json'},
    );
  });

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);

  final server = await io.serve(handler, InternetAddress.loopbackIPv4, 8081);
  print(
    '✅ Mock server listening at http://${server.address.host}:${server.port}',
  );
}
