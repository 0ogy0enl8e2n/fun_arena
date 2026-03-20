class TournamentItem {
  final String id;
  final String name;
  final String sport;
  final String seasonLabel;
  final List<String> favoriteParticipants;
  final bool isPinned;
  final String? notes;

  const TournamentItem({
    required this.id,
    required this.name,
    required this.sport,
    required this.seasonLabel,
    this.favoriteParticipants = const [],
    this.isPinned = false,
    this.notes,
  });

  TournamentItem copyWith({
    String? id,
    String? name,
    String? sport,
    String? seasonLabel,
    List<String>? favoriteParticipants,
    bool? isPinned,
    String? notes,
  }) {
    return TournamentItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sport: sport ?? this.sport,
      seasonLabel: seasonLabel ?? this.seasonLabel,
      favoriteParticipants:
          favoriteParticipants ?? this.favoriteParticipants,
      isPinned: isPinned ?? this.isPinned,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sport': sport,
        'seasonLabel': seasonLabel,
        'favoriteParticipants': favoriteParticipants,
        'isPinned': isPinned,
        'notes': notes,
      };

  factory TournamentItem.fromJson(Map<String, dynamic> json) {
    return TournamentItem(
      id: json['id'] as String,
      name: json['name'] as String,
      sport: json['sport'] as String,
      seasonLabel: json['seasonLabel'] as String,
      favoriteParticipants:
          List<String>.from(json['favoriteParticipants'] as List? ?? []),
      isPinned: json['isPinned'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}
