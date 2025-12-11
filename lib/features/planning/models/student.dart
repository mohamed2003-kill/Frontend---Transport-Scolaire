class Student {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  Student({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
