import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../data/tracking_repository.dart';
import 'location_picker_screen.dart';

class VirtualBus {
  final String id;
  final List<LatLng> routePath;
  final Color color;

  int _currentIndex = 0;
  LatLng _currentPosition;
  bool isMovingForward = true;

  VirtualBus({required this.id, required this.routePath, required this.color})
    : _currentPosition = routePath.isNotEmpty
          ? routePath.first
          : const LatLng(0, 0);

  LatLng get currentPosition => _currentPosition;

  double get progressPct {
    if (routePath.isEmpty) return 0.0;
    return _currentIndex / (routePath.length - 1);
  }

  void tick() {
    if (routePath.isEmpty) return;

    int steps = 1;

    if (isMovingForward) {
      _currentIndex += steps;
      if (_currentIndex >= routePath.length - 1) {
        _currentIndex = routePath.length - 1;
        isMovingForward = false;
      }
    } else {
      _currentIndex -= steps;
      if (_currentIndex <= 0) {
        _currentIndex = 0;
        isMovingForward = true;
      }
    }

    _currentPosition = routePath[_currentIndex];
  }
}

class ScenarioScreen extends StatefulWidget {
  const ScenarioScreen({super.key});

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  final TrackingRepository _repo = TrackingRepository();
  final MapController _mapController = MapController();

  final List<VirtualBus> _fleet = [];

  List<Polyline> _mapPolylines = [];
  List<Marker> _mapMarkers = [];

  Timer? _simTimer;
  bool _isRunning = false;
  bool _isLoadingRoute = false;

  final _idCtrl = TextEditingController();
  LatLng? _startPos;
  LatLng? _endPos;

  final LatLng _initialCenter = const LatLng(33.8938, -5.5473);

  Future<List<LatLng>> _getOptimizedRoute(LatLng start, LatLng end) async {
    final String url =
        'http://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] == null || (data['routes'] as List).isEmpty) {
          return [];
        }
        final List coordinates = data['routes'][0]['geometry']['coordinates'];

        return coordinates.map((coord) {
          return LatLng(coord[1].toDouble(), coord[0].toDouble());
        }).toList();
      } else {
        debugPrint("API Error: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Network Error: $e");
      return [];
    }
  }

  Future<void> _addBus() async {
    if (_idCtrl.text.isEmpty || _startPos == null || _endPos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter ID and Select Start/End points."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoadingRoute = true);

    List<LatLng> routePoints = await _getOptimizedRoute(_startPos!, _endPos!);

    setState(() => _isLoadingRoute = false);

    if (routePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not find a route (check internet/locations)."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final randomColor =
        Colors.primaries[Random().nextInt(Colors.primaries.length)];

    final bus = VirtualBus(
      id: _idCtrl.text,
      routePath: routePoints,
      color: randomColor,
    );

    setState(() {
      _fleet.add(bus);

      _updateMapElements();

      _idCtrl.clear();
      _startPos = null;
      _endPos = null;
    });

    if (routePoints.isNotEmpty) {
      _mapController.move(routePoints.first, 13);
    }
  }

  void _updateMapElements() {
    _mapPolylines = _fleet.map((bus) {
      return Polyline(
        points: bus.routePath,
        color: bus.color.withOpacity(0.7),
        strokeWidth: 4.0,
      );
    }).toList();

    _mapMarkers = _fleet.map((bus) {
      return Marker(
        point: bus.currentPosition,
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: bus.color, width: 2),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Icon(Icons.directions_bus, size: 20, color: bus.color),
        ),
      );
    }).toList();
  }

  void _toggleSimulation() {
    if (_isRunning) {
      _simTimer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);

      _simTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        await _processTick();
      });
    }
  }

  Future<void> _processTick() async {
    for (var bus in _fleet) {
      bus.tick();

      try {
        final pos = bus.currentPosition;
        await _repo.sendLocation(
          entityType: 'bus',
          entityId: bus.id,
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
        debugPrint("Updated ${bus.id} -> ${pos.latitude}, ${pos.longitude}");
      } catch (e) {
        debugPrint("Failed to update ${bus.id}: $e");
      }
    }

    if (mounted) {
      setState(() {
        _updateMapElements();
      });
    }
  }

  void _prefillRandomValues() {
    final random = Random();
    double baseLat = _initialCenter.latitude;
    double baseLng = _initialCenter.longitude;

    double startLat = baseLat + (random.nextDouble() - 0.5) * 0.05;
    double startLng = baseLng + (random.nextDouble() - 0.5) * 0.05;
    double endLat = baseLat + (random.nextDouble() - 0.5) * 0.05;
    double endLng = baseLng + (random.nextDouble() - 0.5) * 0.05;

    setState(() {
      _idCtrl.text = "Bus-${random.nextInt(900) + 100}";
      _startPos = LatLng(startLat, startLng);
      _endPos = LatLng(endLat, endLng);
    });
  }

  Future<void> _pickLocation(bool isStart) async {
    final LatLng center = (isStart ? _startPos : _endPos) ?? _initialCenter;

    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialCenter: center),
      ),
    );

    if (result != null) {
      setState(() {
        if (isStart)
          _startPos = result;
        else
          _endPos = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _prefillRandomValues();
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _idCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Simulation Manager")),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    PolylineLayer(polylines: _mapPolylines),
                    MarkerLayer(markers: _mapMarkers),
                  ],
                ),

                if (_isRunning)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "LIVE",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            flex: 5,
            child: Column(
              children: [
                Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_fleet.length} Buses in Fleet",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: _fleet.isEmpty ? null : _toggleSimulation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRunning
                              ? Colors.red
                              : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_isRunning ? "STOP" : "START"),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text("Add New Route"),
                          initiallyExpanded: _fleet.isEmpty,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _idCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "Bus ID",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildLocationTile(
                                          isStart: true,
                                          location: _startPos,
                                          onTap: () => _pickLocation(true),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildLocationTile(
                                          isStart: false,
                                          location: _endPos,
                                          onTap: () => _pickLocation(false),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: _prefillRandomValues,
                                        child: const Text("Randomize"),
                                      ),
                                      const Spacer(),
                                      ElevatedButton(
                                        onPressed: _isLoadingRoute
                                            ? null
                                            : _addBus,
                                        child: _isLoadingRoute
                                            ? const Text("Computing Route...")
                                            : const Text("Add to Fleet"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _fleet.length,
                          itemBuilder: (ctx, idx) {
                            final bus = _fleet[idx];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: bus.color,
                                child: const Icon(
                                  Icons.directions_bus,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              title: Text(bus.id),
                              subtitle: LinearProgressIndicator(
                                value: bus.progressPct,
                                color: bus.color,
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _fleet.removeAt(idx);
                                    _updateMapElements();
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile({
    required bool isStart,
    required LatLng? location,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Icon(
              isStart ? Icons.circle : Icons.flag,
              color: isStart ? Colors.green : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                location == null
                    ? "Select..."
                    : "${location.latitude.toStringAsFixed(3)},...",
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
