import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/tracking_repository.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final TrackingRepository _repo = TrackingRepository();
  bool _isTracking = false;
  Timer? _timer;
  String _statusLog = "Ready to start engine.";

  // Simulation Config
  final String _entityId = "101"; // Simulating Bus #101
  final String _entityType = "bus";

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      _timer?.cancel();
      setState(() {
        _isTracking = false;
        _statusLog = "Engine stopped.";
      });
    } else {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      setState(() => _isTracking = true);

      // Start loop: Send location every 5 seconds
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        await _sendCurrentLocation();
      });
    }
  }

  Future<void> _sendCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _repo.sendLocation(
        entityType: _entityType,
        entityId: _entityId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _statusLog =
            "Sent: ${position.latitude}, ${position.longitude}\nTime: ${DateTime.now().toLocal()}";
      });
    } catch (e) {
      setState(() => _statusLog = "Error: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bus Driver App (Simulator)")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus,
              size: 100,
              color: _isTracking ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              "Bus ID: $_entityId",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _toggleTracking,
              icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
              label: Text(_isTracking ? "Stop Driving" : "Start Driving"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTracking ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
              color: Colors.black12,
              child: Text(_statusLog, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
