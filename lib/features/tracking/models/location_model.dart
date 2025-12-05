class LocationModel {
  final String entityId;
  final String entityType;
  final double latitude;
  final double longitude;
  final DateTime? timestamp;

  LocationModel({
    required this.entityId,
    required this.entityType,
    required this.latitude,
    required this.longitude,
    this.timestamp,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      entityId: json['entity_id'].toString(),
      entityType: json['entity_type'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}
