class JournalEntry {
  final String id;
  final String title;
  final String dateIso;
  final String? teamId;
  final String? matchId;
  final String mood;
  final String body;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.dateIso,
    this.teamId,
    this.matchId,
    this.mood = 'Neutral',
    required this.body,
  });

  DateTime get date => DateTime.parse(dateIso);

  JournalEntry copyWith({
    String? id,
    String? title,
    String? dateIso,
    String? teamId,
    String? matchId,
    String? mood,
    String? body,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      dateIso: dateIso ?? this.dateIso,
      teamId: teamId ?? this.teamId,
      matchId: matchId ?? this.matchId,
      mood: mood ?? this.mood,
      body: body ?? this.body,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateIso': dateIso,
        'teamId': teamId,
        'matchId': matchId,
        'mood': mood,
        'body': body,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      dateIso: json['dateIso'] as String,
      teamId: json['teamId'] as String?,
      matchId: json['matchId'] as String?,
      mood: json['mood'] as String? ?? 'Neutral',
      body: json['body'] as String,
    );
  }
}
