import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _storage;
  String? _authToken;

  AuthService() : _storage = const FlutterSecureStorage();

  Future<String?> get authToken async {
    if (_authToken != null) return _authToken;
    return await _storage.read(key: 'auth_token');
  }

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    await _storage.delete(key: 'auth_token');
  }

  // JWT 토큰 검증
  bool isTokenValid(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey('YOUR_SECRET_KEY'));
      final expiryDate = jwt.payload['exp'] as int?;
      if (expiryDate == null) return false;

      final expiry = DateTime.fromMillisecondsSinceEpoch(expiryDate * 1000);
      return DateTime.now().isBefore(expiry);
    } catch (e) {
      return false;
    }
  }
}
