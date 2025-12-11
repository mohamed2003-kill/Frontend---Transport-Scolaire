import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:opttrajflutter/models/route.dart';

class ApiService {
  final String _baseUrl = 'http://localhost:8080';

  Future<Route> getOptimalRoute(int busId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/routes/optimal?busId=$busId'),
    );

    if (response.statusCode == 200) {
      return Route.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load optimal route');
    }
  }

  Future<String> getEstimatedArrivalTime(int studentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/routes/eta/$studentId'),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load ETA');
    }
  }

  Future<List<Route>> generateRoutes(String circuitType) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/routes/generate?circuitType=$circuitType'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Route.fromJson(json)).toList();
    } else {
      throw Exception('Failed to generate routes');
    }
  }
}
