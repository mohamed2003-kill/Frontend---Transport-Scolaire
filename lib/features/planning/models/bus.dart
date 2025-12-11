class Bus {
  final int id;
  final String matricule;
  final int capacity;
  final String driverName;

  Bus({
    required this.id,
    required this.matricule,
    required this.capacity,
    required this.driverName,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'],
      matricule: json['matricule'],
      capacity: json['capacity'],
      driverName: json['driverName'],
    );
  }
}
