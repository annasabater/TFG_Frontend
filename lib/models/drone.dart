
class Drone {
  final String id;
  final String sellerId;
  final String model;
  final double price;
  final String? description;
  final String? type;       // 'venta' | 'alquiler'
  final String? condition;  // 'nuevo' | 'usado'
  final String? location;
  final String? contact;
  final String? category;
  final DateTime? createdAt;
  final List<String>? images;

  Drone({
    required this.id,
    required this.sellerId,
    required this.model,
    required this.price,
    this.description,
    this.type,
    this.condition,
    this.location,
    this.contact,
    this.category,
    this.createdAt,
    this.images,
  });

  factory Drone.fromJson(Map<String, dynamic> json) {
    return Drone(
      id: json['_id'] as String,
      sellerId: json['sellerId'] as String,
      model: json['model'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      type: json['type'] as String?,
      condition: json['condition'] as String?,
      location: json['location'] as String?,
      contact: json['contact'] as String?,
      category: json['category'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sellerId': sellerId,
      'model': model,
      'price': price,
      'description': description,
      'type': type,
      'condition': condition,
      'location': location,
      'contact': contact,
      'category': category,
      'createdAt': createdAt?.toIso8601String(),
      'images': images,
    };
  }
}
