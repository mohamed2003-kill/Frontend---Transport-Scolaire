import 'package:dio/dio.dart';
import '../models/location_model.dart';

class TrackingRepository {
  final Dio _dio;

  // Replace with your local IP if testing on emulator (e.g., 10.0.2.2 for Android)
  // or your LAN IP (e.g., 192.168.1.X) if testing on real device.
  static const String baseUrl = 'http://localhost:8080/';

  TrackingRepository() : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  // POST: Send GPS Data
  Future<void> sendLocation({
    required String entityType, // 'bus' or 'student'
    required String entityId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // NOTE: Using queryParameters because FastAPI 'Depends()' usually reads from query
      await _dio.post(
        '/locations/$entityType/$entityId',
        queryParameters: {'latitude': latitude, 'longitude': longitude},
      );
    } catch (e) {
      throw Exception('Failed to send location: $e');
    }
  }

  // GET: Fetch all latest positions
  Future<List<LocationModel>> getEntityLocations() async {
    try {
      print("hna");
      final response = await _dio.get('entities/locations');
      final List data = response.data;
      print(data);
      return data.map((json) => LocationModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching locations: $e');
      return [];
    }
  }
}
