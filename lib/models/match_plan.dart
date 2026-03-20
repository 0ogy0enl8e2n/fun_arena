class MatchPlan {
  final String id;
  final String teamName;
  final String opponentName;
  final String sport;
  final String? tournament;
  final String dateTimeIso;
  final String? watchMethod;
  final String status;
  final bool reminderEnabled;
  final int reminderOffsetMinutes;
  final String? notes;

  const MatchPlan({
    required this.id,
    required this.teamName,
    required this.opponentName,
    required this.sport,
    this.tournament,
    required this.dateTimeIso,
    this.watchMethod,
    this.status = 'planned',
    this.reminderEnabled = false,
    this.reminderOffsetMinutes = 60,
    this.notes,
  });

  DateTime get dateTime => DateTime.parse(dateTimeIso);

  MatchPlan copyWith({
    String? id,
    String? teamName,
    String? opponentName,
    String? sport,
    String? tournament,
    String? dateTimeIso,
    String? watchMethod,
    String? status,
    bool? reminderEnabled,
    int? reminderOffsetMinutes,
    String? notes,
  }) {
    return MatchPlan(
      id: id ?? this.id,
      teamName: teamName ?? this.teamName,
      opponentName: opponentName ?? this.opponentName,
      sport: sport ?? this.sport,
      tournament: tournament ?? this.tournament,
      dateTimeIso: dateTimeIso ?? this.dateTimeIso,
      watchMethod: watchMethod ?? this.watchMethod,
      status: status ?? this.status,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderOffsetMinutes:
          reminderOffsetMinutes ?? this.reminderOffsetMinutes,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamName': teamName,
        'opponentName': opponentName,
        'sport': sport,
        'tournament': tournament,
        'dateTimeIso': dateTimeIso,
        'watchMethod': watchMethod,
        'status': status,
        'reminderEnabled': reminderEnabled,
        'reminderOffsetMinutes': reminderOffsetMinutes,
        'notes': notes,
      };

  factory MatchPlan.fromJson(Map<String, dynamic> json) {
    return MatchPlan(
      id: json['id'] as String,
      teamName: json['teamName'] as String,
      opponentName: json['opponentName'] as String,
      sport: json['sport'] as String,
      tournament: json['tournament'] as String?,
      dateTimeIso: json['dateTimeIso'] as String,
      watchMethod: json['watchMethod'] as String?,
      status: json['status'] as String? ?? 'planned',
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderOffsetMinutes:
          json['reminderOffsetMinutes'] as int? ?? 60,
      notes: json['notes'] as String?,
    );
  }
}
