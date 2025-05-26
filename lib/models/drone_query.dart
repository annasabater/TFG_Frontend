//lib/models/drone_query.dart

/// Paràmetres de filtre per a GET /api/drones
class DroneQuery {
  final String? q, category, condition, location;
  final double? minPrice, maxPrice;
  final int? page, limit;

  const DroneQuery({
    this.q,
    this.category,
    this.condition,
    this.location,
    this.minPrice,
    this.maxPrice,
    this.page,
    this.limit,
  });

  /// Converteix l’objecte en map per a `Uri.replace(queryParameters: …)`
  Map<String, String> toQueryParams() => {
        if (q != null && q!.isNotEmpty) 'q': q!,
        if (category != null && category!.isNotEmpty) 'category': category!,
        if (condition != null && condition!.isNotEmpty) 'condition': condition!,
        if (location != null && location!.isNotEmpty) 'location': location!,
        if (minPrice != null) 'minPrice': minPrice!.toString(),
        if (maxPrice != null) 'maxPrice': maxPrice!.toString(),
        if (page != null) 'page': page.toString(),
        if (limit != null) 'limit': limit.toString(),
      };

  /// Permet actualitzar nuls i pàgina (afegit)
  DroneQuery copyWith({
    String? q,
    String? category,
    String? condition,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? page,
    int? limit,
  }) {
    return DroneQuery(
      q: q ?? this.q,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}
