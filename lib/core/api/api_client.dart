// Placeholder file - implement API client and base HTTP configurations
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthHttpClient {
  final _storage = const FlutterSecureStorage();
  final _client = http.Client();

  Future<String?> _loadToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<http.Response> get(Uri url) async {
    final token = await _loadToken();
    return _client.get(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> post(Uri url, {Object? body}) async {
    final token = await _loadToken();
    return _client.post(
      url,
      body: body,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> put(Uri url, {Object? body}) async {
    final token = await _loadToken();
    return _client.put(
      url,
      body: body,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> delete(Uri url) async {
    final token = await _loadToken();
    return _client.delete(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}
