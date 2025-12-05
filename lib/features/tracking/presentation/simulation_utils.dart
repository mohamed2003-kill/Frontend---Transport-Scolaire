import 'package:latlong2/latlong.dart';

class VirtualBus {
  final String id;
  final LatLng start;
  final LatLng end;
  final double speedFactor; // How fast it moves (0.01 to 0.1 per tick)

  double _progress = 0.0; // 0.0 = Start, 1.0 = End
  bool isMovingForward = true; // To make it go back and forth (Ping Pong)

  VirtualBus({
    required this.id,
    required this.start,
    required this.end,
    this.speedFactor = 0.02, // Default speed
  });

  // Calculate current position based on progress
  LatLng get currentPosition {
    final lat = start.latitude + (end.latitude - start.latitude) * _progress;
    final lng = start.longitude + (end.longitude - start.longitude) * _progress;
    return LatLng(lat, lng);
  }

  // Move the bus one step
  void tick() {
    if (isMovingForward) {
      _progress += speedFactor;
      if (_progress >= 1.0) {
        _progress = 1.0;
        isMovingForward = false; // Turn around
      }
    } else {
      _progress -= speedFactor;
      if (_progress <= 0.0) {
        _progress = 0.0;
        isMovingForward = true; // Turn around
      }
    }
  }

  double get progressPct => _progress;
}
