class DroneZone {
  final String id;
  final String name;
  final String description;
  final List<double> coordinates; // [lat1, lng1, lat2, lng2, ...]
  final String type; // restricted, allowed, etc.
  final String color; // Color en formato hex

  DroneZone({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinates,
    required this.type,
    required this.color,
  });

  factory DroneZone.fromJson(Map<String, dynamic> json) {
    return DroneZone(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coordinates: List<double>.from(json['coordinates'] ?? []),
      type: json['type'] ?? 'restricted',
      color: json['color'] ?? '#FF0000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coordinates': coordinates,
      'type': type,
      'color': color,
    };
  }
} 