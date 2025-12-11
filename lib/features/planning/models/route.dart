class Route {
  final int busId;
  final List<int> studentIds;
  final String routeDetails;
  final String circuitType;

  Route({
    required this.busId,
    required this.studentIds,
    required this.routeDetails,
    required this.circuitType,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      busId: json['busId'],
      studentIds: List<int>.from(json['studentIds']),
      routeDetails: json['routeDetails'],
      circuitType: json['circuitType'],
    );
  }
}
