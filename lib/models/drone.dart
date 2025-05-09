class Rating {
  final String userId;
  final int    rating;
  final String comment;

  Rating({required this.userId, required this.rating, required this.comment});

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        userId : json['userId'] as String,
        rating : json['rating'] as int,
        comment: json['comment'] as String,
      );

  Map<String, dynamic> toJson() =>
      {'userId': userId, 'rating': rating, 'comment': comment};
}

class Drone {
  final String id;
  final String ownerId;           // backend: ownerId / sellerId
  final String model;
  final double price;
  final String? description;
  final String? type;             // venta | alquiler
  final String? condition;        // nuevo | usado
  final String? location;
  final String? contact;
  final String? category;
  final DateTime? createdAt;
  final List<String>? images;
  final List<Rating> ratings;
  final String? status;           // pending | sold (opcional)

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
  });

  factory Drone.fromJson(Map<String, dynamic> json) => Drone(
        id         : json['_id'] as String,
        ownerId    : (json['ownerId'] ?? json['sellerId']) as String,
        model      : json['model'] as String,
        price      : (json['price'] as num).toDouble(),
        description: json['details'] ?? json['description'],
        type       : json['type'] ?? json['category'],
        condition  : json['condition'],
        location   : json['location'],
        contact    : json['contact'],
        category   : json['category'],
        status     : json['status'] as String?,
        createdAt  : json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        images     : (json['images'] as List?)?.cast<String>(),
        ratings    : (json['ratings'] as List<dynamic>? ?? [])
            .map((e) => Rating.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        '_id'      : id,
        'ownerId'  : ownerId,
        'model'    : model,
        'price'    : price,
        'details'  : description,
        'type'     : type,
        'condition': condition,
        'location' : location,
        'contact'  : contact,
        'category' : category,
        'createdAt': createdAt?.toIso8601String(),
        'images'   : images,
        'status'   : status,
      };
}
