import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:opttrajflutter/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:opttrajflutter/models/route.dart'
    as app_route; // Renaming to avoid conflict with Material's Route

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _busIdController = TextEditingController();
  final _studentIdController = TextEditingController();
  String _eta = '';

  final MapController _mapController = MapController();

  // NOUVEAU: Une liste pour contenir toutes les polylignes des routes générées
  List<Polyline> _routePolylines = [];
  List<Marker> _markers = [];

  static final LatLng _schoolLocation = LatLng(33.8935, -5.5473);

  @override
  void initState() {
    super.initState();
    _addSchoolMarker();
  }

  void _addSchoolMarker() {
    _markers = [
      Marker(
        point: _schoolLocation,
        width: 80,
        height: 80,
        child: const Icon(Icons.school, color: Colors.red, size: 40),
      ),
    ];
  }

  // MODIFIÉ: Cette fonction traite une seule route (pour "Get Optimal Route")
  void _drawSingleRoute(String encodedPolyline) {
    final polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePoints =
        polylinePoints.decodePolyline(encodedPolyline);

    setState(() {
      _addSchoolMarker(); // Réinitialise les marqueurs pour n'afficher que l'école
      if (decodedPolylinePoints.isNotEmpty) {
        final coordinates = decodedPolylinePoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
        _routePolylines = [
          Polyline(
            points: coordinates,
            color: Colors.blue,
            strokeWidth: 5,
          ),
        ];
      } else {
        _routePolylines = [];
      }
    });
  }

  // NOUVEAU: Cette fonction traite plusieurs routes (pour "Generate Routes")
  void _drawMultipleRoutes(List<app_route.Route> routes) {
    final polylinePoints = PolylinePoints();
    List<Polyline> newPolylines = [];
    // Couleurs pour différencier les routes
    final List<Color> colors = [
      Colors.purple,
      Colors.orange,
      Colors.green,
      Colors.teal,
      Colors.pink
    ];

    for (int i = 0; i < routes.length; i++) {
      final route = routes[i];
      List<PointLatLng> decodedPoints =
          polylinePoints.decodePolyline(route.routeDetails);
      if (decodedPoints.isNotEmpty) {
        final coordinates = decodedPoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
        newPolylines.add(
          Polyline(
            points: coordinates,
            color: colors[i %
                colors
                    .length], // Utilise une couleur différente pour chaque route
            strokeWidth: 5,
          ),
        );
      }
    }

    setState(() {
      _addSchoolMarker(); // Réinitialise les marqueurs
      _routePolylines =
          newPolylines; // Met à jour la carte avec toutes les nouvelles routes
    });
  }

  // NOUVELLE MÉTHODE: Logique pour la génération de routes
  Future<void> _handleGenerateRoutes(String circuitType) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      // 1. On stocke le résultat de l'API dans une variable
      final List<app_route.Route> generatedRoutes =
          await apiService.generateRoutes(circuitType);

      // 2. On appelle la nouvelle fonction pour dessiner les routes
      _drawMultipleRoutes(generatedRoutes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${circuitType.capitalize()} routes generated and displayed!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating routes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OptTraj Flutter (OSM/OSRM)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Input Fields and Buttons ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _busIdController,
                    decoration: const InputDecoration(labelText: 'Bus ID'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_busIdController.text.isEmpty) return;
                    final apiService =
                        Provider.of<ApiService>(context, listen: false);
                    try {
                      final route = await apiService
                          .getOptimalRoute(int.parse(_busIdController.text));
                      // On utilise la fonction pour une seule route
                      _drawSingleRoute(route.routeDetails);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error getting route: $e')),
                      );
                    }
                  },
                  child: const Text('Get Optimal Route'),
                ),
              ],
            ),
            // ... (le reste des champs de texte et boutons ETA ne change pas)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(labelText: 'Student ID'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_studentIdController.text.isEmpty) return;
                    final apiService =
                        Provider.of<ApiService>(context, listen: false);
                    try {
                      final eta = await apiService.getEstimatedArrivalTime(
                          int.parse(_studentIdController.text));
                      setState(() {
                        _eta = eta;
                      });
                    } catch (e) {
                      setState(() {
                        _eta = 'Error fetching ETA';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text('Get ETA'),
                ),
              ],
            ),
            if (_eta.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('ETA: $_eta', style: const TextStyle(fontSize: 16)),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // MODIFIÉ: Appel de la nouvelle méthode
                ElevatedButton(
                  onPressed: () => _handleGenerateRoutes('morning'),
                  child: const Text('Generate Morning Routes'),
                ),
                // MODIFIÉ: Appel de la nouvelle méthode
                ElevatedButton(
                  onPressed: () => _handleGenerateRoutes('evening'),
                  child: const Text('Generate Evening Routes'),
                ),
              ],
            ),

            // --- Map Widget ---
            Expanded(
              child: Card(
                margin: const EdgeInsets.only(top: 16),
                elevation: 4,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _schoolLocation,
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    // MODIFIÉ: Utilise la nouvelle liste de polylignes
                    PolylineLayer(polylines: _routePolylines),
                    MarkerLayer(markers: _markers),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Petite extension pour mettre la première lettre en majuscule
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
