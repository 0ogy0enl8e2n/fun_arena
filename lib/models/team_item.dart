class TeamItem {
  final String id;
  final String name;
  final String sport;
  final String colorTag;
  final String? league;
  final String? rivalNote;
  final bool isFavorite;
  final String? notes;

  const TeamItem({
    required this.id,
    required this.name,
    required this.sport,
    this.colorTag = 'blue',
    this.league,
    this.rivalNote,
    this.isFavorite = false,
    this.notes,
  });

  TeamItem copyWith({
    String? id,
    String? name,
    String? sport,
    String? colorTag,
    String? league,
    String? rivalNote,
    bool? isFavorite,
    String? notes,
  }) {
    return TeamItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sport: sport ?? this.sport,
      colorTag: colorTag ?? this.colorTag,
      league: league ?? this.league,
      rivalNote: rivalNote ?? this.rivalNote,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sport': sport,
        'colorTag': colorTag,
        'league': league,
        'rivalNote': rivalNote,
        'isFavorite': isFavorite,
        'notes': notes,
      };

  factory TeamItem.fromJson(Map<String, dynamic> json) {
    return TeamItem(
      id: json['id'] as String,
      name: json['name'] as String,
      sport: json['sport'] as String,
      colorTag: json['colorTag'] as String? ?? 'blue',
      league: json['league'] as String?,
      rivalNote: json['rivalNote'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}
