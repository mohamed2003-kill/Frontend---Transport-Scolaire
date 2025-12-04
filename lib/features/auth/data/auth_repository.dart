import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:transport_scolaire/features/auth/data/auth_api.dart';

class AuthRepository {
  final AuthApi _authApi;
  final _storage = const FlutterSecureStorage();

  AuthRepository(this._authApi);

  Future<void> login(String email, String password) async {
    final authResponse = await _authApi.login(email, password);
    await _storage.write(key: 'auth_token', value: authResponse.accessToken);
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    await _authApi.register(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }
}
