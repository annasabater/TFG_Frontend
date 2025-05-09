//lib/models/game.dart
class Game {
  final String id;
  final String name;
  final String type;       // 'carreras' | 'competencia' | 'obstaculos'
  final int maxPlayers;
  final List<String> players;
  final DateTime? createdAt;

  Game({
    required this.id,
    required this.name,
    required this.type,
    required this.maxPlayers,
    required this.players,
    this.createdAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      maxPlayers: json['maxPlayers'] as int,
      players: (json['players'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'type': type,
      'maxPlayers': maxPlayers,
      'players': players,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
