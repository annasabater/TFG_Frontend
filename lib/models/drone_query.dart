//lib/models/drone_query.dart
/// Paràmetres de filtre per a GET /api/drones
class DroneQuery {
  final String? q, category, condition, location;
  final double? priceMin, priceMax;
  final int? page, limit;

  const DroneQuery({
    this.q,
    this.category,
    this.condition,
    this.location,
    this.priceMin,
    this.priceMax,
    this.page,
    this.limit,
  });

  /// Converteix l’objecte en map per a `Uri.replace(queryParameters: …)`
  Map<String, String> toQueryParams() => {
        if (q != null && q!.isNotEmpty) 'q': q!,
        if (category != null && category!.isNotEmpty) 'category': category!,
        if (condition != null && condition!.isNotEmpty) 'condition': condition!,
        if (location != null && location!.isNotEmpty) 'location': location!,
        if (priceMin != null) 'priceMin': priceMin!.toString(),
        if (priceMax != null) 'priceMax': priceMax!.toString(),
        if (page != null) 'page': page.toString(),
        if (limit != null) 'limit': limit.toString(),
      };
}
