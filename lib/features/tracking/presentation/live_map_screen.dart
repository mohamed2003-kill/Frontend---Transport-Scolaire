import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/tracking_repository.dart';
import '../models/location_model.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final TrackingRepository _repo = TrackingRepository();
  final MapController _mapController = MapController();

  List<LocationModel> _locations = [];
  Timer? _pollingTimer;
  bool _hasInitialFocus = false;

  // Dropdown Logic
  bool _showDropdown = true;
  String? _selectedBusId; // The ID currently selected in the dropdown

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final data = await _repo.getEntityLocations();
      if (mounted) {
        setState(() {
          _locations = data;
        });

        if (data.isNotEmpty && !_hasInitialFocus) {
          _zoomToFitMarkers(data);
          _hasInitialFocus = true;
        }

        // If a bus is selected, keep following it?
        // Or just let the marker move.
        // For now, we just update the data.
      }
    });
  }

  void _zoomToFitMarkers(List<LocationModel> locations) {
    if (locations.isEmpty) return;
    final points = locations
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50.0)),
    );
  }

  // Focus on specific bus
  void _focusOnBus(String busId) {
    final bus = _locations.firstWhere(
      (element) => element.entityId == busId,
      orElse: () => _locations.first,
    );

    _mapController.move(
      LatLng(bus.latitude, bus.longitude),
      16.0, // High zoom level
    );

    setState(() {
      _selectedBusId = busId;
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Fleet Tracking"),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () => _zoomToFitMarkers(_locations),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. THE MAP
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(33.8938, -5.5473),

              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: _locations.map((loc) {
                  // Highlight selected bus
                  final isSelected = loc.entityId == _selectedBusId;
                  return Marker(
                    point: LatLng(loc.latitude, loc.longitude),
                    width: isSelected ? 80 : 60,
                    height: isSelected ? 80 : 60,
                    child: _buildMarkerIcon(loc, isSelected),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. THE FLOATING DROPDOWN PANEL
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Toggle Button
                FloatingActionButton.small(
                  backgroundColor: Colors.white,
                  child: Icon(
                    _showDropdown
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Colors.black,
                  ),
                  onPressed: () =>
                      setState(() => _showDropdown = !_showDropdown),
                ),
                const SizedBox(height: 10),

                // The Dropdown Card
                if (_showDropdown)
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: const Text("Select a Bus to Track"),
                                value:
                                    _locations.any(
                                      (e) => e.entityId == _selectedBusId,
                                    )
                                    ? _selectedBusId
                                    : null, // Reset if bus disappears
                                isExpanded: true,
                                items: _locations.map((loc) {
                                  return DropdownMenuItem(
                                    value: loc.entityId,
                                    child: Text(
                                      "${loc.entityType.toUpperCase()} - ${loc.entityId}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) _focusOnBus(value);
                                },
                              ),
                            ),
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

  Widget _buildMarkerIcon(LocationModel loc, bool isSelected) {
    return Column(
      children: [
        Icon(
          loc.entityType == 'bus' ? Icons.directions_bus : Icons.person_pin,
          color: isSelected
              ? Colors.red
              : (loc.entityType == 'bus' ? Colors.blue : Colors.orange),
          size: isSelected ? 40 : 30, // Bigger if selected
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.yellow : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            loc.entityId,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
