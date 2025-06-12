// lib/models/drone.dart

class Rating {
  final String userId;
  final int rating;
  final String comment;

  Rating({required this.userId, required this.rating, required this.comment});

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    userId: json['userId'] as String,
    rating: json['rating'] as int,
    comment: json['comment'] as String,
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'rating': rating,
    'comment': comment,
  };
}

/* -------------------------------------------------------------------------- */
/*                                  DRONE                                     */
/* -------------------------------------------------------------------------- */

class Drone {
  final String id;
  final String ownerId; // backend: ownerId / sellerId
  final String model;
  final double price;

  final String? description;
  final String? type; // compra | servei
  final String? condition; // new | likeNew | used
  final String? location;
  final String? contact;
  final String? category;

  final DateTime? createdAt;
  final List<String>? images;
  final List<Rating> ratings;

  final String? status; // pending | sold  (si vols mostrar-ho)
  final bool isSold; // nou camp
  final bool isService; // nou camp (true si és anunci de servei)
  final int? stock;

  Drone({
    required this.id,
    required this.ownerId,
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
    this.ratings = const [],
    this.status,
    this.isSold = false,
    this.isService = false,
    this.stock,
  });

  /* --------------------------- JSON helpers --------------------------- */

  factory Drone.fromJson(Map<String, dynamic> json) => Drone(
    id: json['_id'] as String,
    ownerId: (json['ownerId'] ?? json['sellerId']) as String,
    model: json['model'] as String,
    price: (json['price'] as num).toDouble(),

    description: json['details'] ?? json['description'],
    type: json['type'] ?? json['category'],
    condition: json['condition'],
    location: json['location'],
    contact: json['contact'],
    category: json['category'],

    status: json['status'] as String?,
    isSold: json['isSold'] ?? false,
    isService: json['isService'] ?? false,
    stock: json['stock'] as int?,

    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    images: (json['images'] as List?)?.cast<String>(),
    ratings:
        (json['ratings'] as List<dynamic>? ?? [])
            .map((e) => Rating.fromJson(e as Map<String, dynamic>))
            .toList(),
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'ownerId': ownerId,
    'model': model,
    'price': price,

    'details': description,
    'type': type,
    'condition': condition,
    'location': location,
    'contact': contact,
    'category': category,

    'status': status,
    'isSold': isSold,
    'isService': isService,
    'stock': stock,

    'createdAt': createdAt?.toIso8601String(),
    'images': images,
    // ratings siempre como array, nunca string
    'ratings':
        ratings.isNotEmpty
            ? ratings.map((r) => r.toJson()).toList()
            : <dynamic>[],
  };
}
