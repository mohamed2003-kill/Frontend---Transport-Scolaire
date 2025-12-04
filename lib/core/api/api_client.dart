import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['BASE_URL']!,
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach JWT token if available
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Required for Flutter Web CORS when credentials are used
          options.extra['withCredentials'] = true;

          handler.next(options);
        },
      ),
    );
  }

  Future<Response> get(String path, {Options? options}) async {
    return _dio.get(path, options: options);
  }

  Future<Response> post(String path, {Object? data, Options? options}) async {
    return _dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path, {Object? data, Options? options}) async {
    return _dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path, {Options? options}) async {
    return _dio.delete(path, options: options);
  }
}
