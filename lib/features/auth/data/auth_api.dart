import 'package:dio/dio.dart';
import 'package:transport_scolaire/core/api/api_client.dart';
import 'package:transport_scolaire/features/auth/models/auth_response.dart';

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      options: Options(
        headers: {'Content-Type': 'application/json'},
        extra: {
          'withCredentials':
              true, // important for cookies/session in Flutter Web
        },
      ),
    );

    return AuthResponse.fromJson(response.data);
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    await _apiClient.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': role,
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
        extra: {
          'withCredentials': true, // also needed if registration sets cookies
        },
      ),
    );
  }

  Future<List<String>> getRoles(String userId) async {
    final response = await _apiClient.get(
      '/auth/roles/$userId',
      options: Options(
        extra: {'withCredentials': true}, // attach cookies if needed
      ),
    );
    return List<String>.from(response.data);
  }
}
