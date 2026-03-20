import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/team_item.dart';
import '../models/match_plan.dart';
import '../models/prediction_item.dart';
import '../models/journal_entry.dart';
import '../models/tournament_item.dart';
import '../services/storage_service.dart';

class AppDataProvider extends ChangeNotifier {
  final StorageService _storage;
  static const _uuid = Uuid();

  AppDataProvider(this._storage);

  UserProfile _profile = const UserProfile();
  List<TeamItem> _teams = [];
  List<MatchPlan> _matches = [];
  List<PredictionItem> _predictions = [];
  List<JournalEntry> _journalEntries = [];
  List<TournamentItem> _tournaments = [];
  bool _onboardingCompleted = false;
  bool _isLoading = true;

  UserProfile get profile => _profile;
  List<TeamItem> get teams => List.unmodifiable(_teams);
  List<MatchPlan> get matches => List.unmodifiable(_matches);
  List<PredictionItem> get predictions => List.unmodifiable(_predictions);
  List<JournalEntry> get journalEntries =>
      List.unmodifiable(_journalEntries);
  List<TournamentItem> get tournaments => List.unmodifiable(_tournaments);
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isLoading => _isLoading;

  String get themeMode => _profile.themeMode;
  ThemeMode get themeModeEnum => switch (_profile.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  List<TeamItem> get favoriteTeams =>
      _teams.where((t) => t.isFavorite).toList();

  List<MatchPlan> get upcomingMatches {
    final now = DateTime.now();
    return _matches
        .where((m) => m.status == 'planned' && m.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<JournalEntry> get recentJournalEntries {
    final sorted = List<JournalEntry>.from(_journalEntries)
      ..sort((a, b) => b.dateIso.compareTo(a.dateIso));
    return sorted.take(5).toList();
  }

  List<TournamentItem> get pinnedTournaments =>
      _tournaments.where((t) => t.isPinned).toList();

  static String generateId(String prefix) => '${prefix}_${_uuid.v4()}';

  Future<void> loadAll() async {
    _onboardingCompleted = _storage.onboardingCompleted;
    _profile = _storage.getProfile();
    _teams = _storage.getTeams();
    _matches = _storage.getMatches();
    _predictions = _storage.getPredictions();
    _journalEntries = _storage.getJournalEntries();
    _tournaments = _storage.getTournaments();
    _isLoading = false;
    notifyListeners();
  }

  // --- Onboarding ---

  Future<void> completeOnboarding(UserProfile profileData) async {
    _profile = profileData;
    _onboardingCompleted = true;
    await _storage.saveProfile(profileData);
    await _storage.setOnboardingCompleted(true);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _onboardingCompleted = false;
    await _storage.setOnboardingCompleted(false);
    notifyListeners();
  }

  // --- Profile ---

  Future<void> updateProfile(UserProfile updated) async {
    _profile = updated;
    await _storage.saveProfile(updated);
    await _storage.setThemeMode(updated.themeMode);
    notifyListeners();
  }

  Future<void> updateNickname(String nickname) async {
    await updateProfile(_profile.copyWith(nickname: nickname));
  }

  Future<void> setThemeMode(String mode) async {
    await updateProfile(_profile.copyWith(themeMode: mode));
  }

  // --- Teams ---

  Future<void> addTeam(TeamItem team) async {
    _teams.add(team);
    await _storage.saveTeams(_teams);
    notifyListeners();
  }

  Future<void> updateTeam(TeamItem team) async {
    final idx = _teams.indexWhere((t) => t.id == team.id);
    if (idx >= 0) {
      _teams[idx] = team;
      await _storage.saveTeams(_teams);
      notifyListeners();
    }
  }

  Future<void> deleteTeam(String id) async {
    _teams.removeWhere((t) => t.id == id);
    await _storage.saveTeams(_teams);
    notifyListeners();
  }

  Future<void> toggleTeamFavorite(String id) async {
    final idx = _teams.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _teams[idx] = _teams[idx].copyWith(isFavorite: !_teams[idx].isFavorite);
      await _storage.saveTeams(_teams);
      notifyListeners();
    }
  }

  TeamItem? getTeamById(String id) {
    try {
      return _teams.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Matches ---

  Future<void> addMatch(MatchPlan match) async {
    _matches.add(match);
    await _storage.saveMatches(_matches);
    notifyListeners();
  }

  Future<void> updateMatch(MatchPlan match) async {
    final idx = _matches.indexWhere((m) => m.id == match.id);
    if (idx >= 0) {
      _matches[idx] = match;
      await _storage.saveMatches(_matches);
      notifyListeners();
    }
  }

  Future<void> deleteMatch(String id) async {
    _matches.removeWhere((m) => m.id == id);
    _predictions.removeWhere((p) => p.matchId == id);
    await _storage.saveMatches(_matches);
    await _storage.savePredictions(_predictions);
    notifyListeners();
  }

  Future<void> updateMatchStatus(String id, String status) async {
    final idx = _matches.indexWhere((m) => m.id == id);
    if (idx >= 0) {
      _matches[idx] = _matches[idx].copyWith(status: status);
      await _storage.saveMatches(_matches);
      notifyListeners();
    }
  }

  MatchPlan? getMatchById(String id) {
    try {
      return _matches.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Predictions ---

  Future<void> addPrediction(PredictionItem prediction) async {
    _predictions.add(prediction);
    await _storage.savePredictions(_predictions);
    notifyListeners();
  }

  Future<void> updatePrediction(PredictionItem prediction) async {
    final idx = _predictions.indexWhere((p) => p.id == prediction.id);
    if (idx >= 0) {
      _predictions[idx] = prediction;
      await _storage.savePredictions(_predictions);
      notifyListeners();
    }
  }

  Future<void> deletePrediction(String id) async {
    _predictions.removeWhere((p) => p.id == id);
    await _storage.savePredictions(_predictions);
    notifyListeners();
  }

  PredictionItem? getPredictionForMatch(String matchId) {
    try {
      return _predictions.firstWhere((p) => p.matchId == matchId);
    } catch (_) {
      return null;
    }
  }

  // --- Journal ---

  Future<void> addJournalEntry(JournalEntry entry) async {
    _journalEntries.add(entry);
    await _storage.saveJournalEntries(_journalEntries);
    notifyListeners();
  }

  Future<void> updateJournalEntry(JournalEntry entry) async {
    final idx = _journalEntries.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      _journalEntries[idx] = entry;
      await _storage.saveJournalEntries(_journalEntries);
      notifyListeners();
    }
  }

  Future<void> deleteJournalEntry(String id) async {
    _journalEntries.removeWhere((e) => e.id == id);
    await _storage.saveJournalEntries(_journalEntries);
    notifyListeners();
  }

  // --- Tournaments ---

  Future<void> addTournament(TournamentItem tournament) async {
    _tournaments.add(tournament);
    await _storage.saveTournaments(_tournaments);
    notifyListeners();
  }

  Future<void> updateTournament(TournamentItem tournament) async {
    final idx = _tournaments.indexWhere((t) => t.id == tournament.id);
    if (idx >= 0) {
      _tournaments[idx] = tournament;
      await _storage.saveTournaments(_tournaments);
      notifyListeners();
    }
  }

  Future<void> deleteTournament(String id) async {
    _tournaments.removeWhere((t) => t.id == id);
    await _storage.saveTournaments(_tournaments);
    notifyListeners();
  }

  Future<void> toggleTournamentPin(String id) async {
    final idx = _tournaments.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _tournaments[idx] =
          _tournaments[idx].copyWith(isPinned: !_tournaments[idx].isPinned);
      await _storage.saveTournaments(_tournaments);
      notifyListeners();
    }
  }

  // --- Data Management ---

  Map<String, dynamic> exportData() => _storage.exportAll();

  Future<void> importData(Map<String, dynamic> data) async {
    await _storage.importAll(data);
    await loadAll();
  }

  Future<void> clearAllData() async {
    await _storage.clearAll();
    _profile = const UserProfile();
    _teams = [];
    _matches = [];
    _predictions = [];
    _journalEntries = [];
    _tournaments = [];
    _onboardingCompleted = false;
    notifyListeners();
  }

  // --- Demo Data ---

  Future<void> fillDemoData() async {
    final now = DateTime.now();

    final demoTeams = [
      TeamItem(
        id: generateId('team'),
        name: 'City Hawks',
        sport: 'Basketball',
        colorTag: 'blue',
        league: 'National Basketball League',
        rivalNote: 'Big rivalry with River Lions',
        isFavorite: true,
        notes: 'Strong home record this season',
      ),
      TeamItem(
        id: generateId('team'),
        name: 'Northern FC',
        sport: 'Football',
        colorTag: 'red',
        league: 'Premier Division',
        rivalNote: 'Local derby vs Mountain FC',
        isFavorite: true,
        notes: 'Following since 2018',
      ),
      TeamItem(
        id: generateId('team'),
        name: 'Thunderbolts',
        sport: 'Hockey',
        colorTag: 'teal',
        league: 'Pro Hockey League',
        isFavorite: false,
        notes: 'Great defense lineup',
      ),
      TeamItem(
        id: generateId('team'),
        name: 'Ace Masters',
        sport: 'Tennis',
        colorTag: 'green',
        isFavorite: false,
      ),
      TeamItem(
        id: generateId('team'),
        name: 'Storm Racing',
        sport: 'Motorsport',
        colorTag: 'orange',
        league: 'Grand Prix Series',
        isFavorite: true,
        notes: 'Best pit crew in the league',
      ),
    ];

    final matchWatched1Id = generateId('match');
    final matchWatched2Id = generateId('match');
    final matchMissedId = generateId('match');
    final matchUpcoming1Id = generateId('match');
    final matchUpcoming2Id = generateId('match');
    final matchUpcoming3Id = generateId('match');

    final demoMatches = [
      MatchPlan(
        id: matchUpcoming1Id,
        teamName: 'City Hawks',
        opponentName: 'River Lions',
        sport: 'Basketball',
        tournament: 'Spring Cup 2026',
        dateTimeIso: now.add(const Duration(days: 2, hours: 3)).toIso8601String(),
        watchMethod: 'Home TV',
        status: 'planned',
        reminderEnabled: true,
        reminderOffsetMinutes: 60,
        notes: 'Semi-final game! Watch with friends',
      ),
      MatchPlan(
        id: matchUpcoming2Id,
        teamName: 'Northern FC',
        opponentName: 'Blue Harbor',
        sport: 'Football',
        tournament: 'Premier Division',
        dateTimeIso: now.add(const Duration(days: 5)).toIso8601String(),
        watchMethod: 'Stadium - Section B',
        status: 'planned',
        reminderEnabled: true,
        reminderOffsetMinutes: 180,
        notes: 'Got tickets for this one!',
      ),
      MatchPlan(
        id: matchUpcoming3Id,
        teamName: 'Storm Racing',
        opponentName: 'Various',
        sport: 'Motorsport',
        tournament: 'Grand Prix Round 4',
        dateTimeIso: now.add(const Duration(days: 8)).toIso8601String(),
        watchMethod: 'Sports Channel HD',
        status: 'planned',
        reminderEnabled: false,
      ),
      MatchPlan(
        id: matchWatched1Id,
        teamName: 'City Hawks',
        opponentName: 'Star Flyers',
        sport: 'Basketball',
        tournament: 'Spring Cup 2026',
        dateTimeIso: now.subtract(const Duration(days: 3)).toIso8601String(),
        watchMethod: 'Sports Bar',
        status: 'watched',
        notes: 'What a comeback in the 4th quarter!',
      ),
      MatchPlan(
        id: matchWatched2Id,
        teamName: 'Thunderbolts',
        opponentName: 'Ice Bears',
        sport: 'Hockey',
        tournament: 'Pro Hockey League',
        dateTimeIso: now.subtract(const Duration(days: 7)).toIso8601String(),
        watchMethod: 'Arena - Row 12',
        status: 'watched',
        notes: 'First live hockey game this season',
      ),
      MatchPlan(
        id: matchMissedId,
        teamName: 'Northern FC',
        opponentName: 'Mountain FC',
        sport: 'Football',
        tournament: 'Premier Division',
        dateTimeIso: now.subtract(const Duration(days: 10)).toIso8601String(),
        status: 'missed',
        notes: 'Had to work, heard it was a great derby',
      ),
    ];

    final demoPredictions = [
      PredictionItem(
        id: generateId('pred'),
        matchId: matchWatched1Id,
        predictedWinner: 'City Hawks',
        confidence: 4,
        reason: 'Hawks have better recent form and home advantage',
        resultStatus: 'correct',
      ),
      PredictionItem(
        id: generateId('pred'),
        matchId: matchWatched2Id,
        predictedWinner: 'Thunderbolts',
        confidence: 3,
        reason: 'Strong defense should hold',
        resultStatus: 'correct',
      ),
      PredictionItem(
        id: generateId('pred'),
        matchId: matchMissedId,
        predictedWinner: 'Northern FC',
        confidence: 5,
        reason: 'Northern always dominates the derby at home',
        resultStatus: 'incorrect',
      ),
      PredictionItem(
        id: generateId('pred'),
        matchId: matchUpcoming1Id,
        predictedWinner: 'City Hawks',
        confidence: 4,
        reason: 'Semi-final momentum and crowd support',
        resultStatus: 'pending',
      ),
    ];

    final demoJournal = [
      JournalEntry(
        id: generateId('journal'),
        title: 'Incredible Hawks comeback!',
        dateIso: now.subtract(const Duration(days: 3)).toIso8601String().split('T')[0],
        teamId: demoTeams[0].id,
        matchId: matchWatched1Id,
        mood: 'Excited',
        body: 'Down by 15 points at halftime, the Hawks pulled off an amazing comeback in the 4th quarter. '
            'The energy in the sports bar was unreal. Johnson hit three consecutive three-pointers to seal the deal. '
            'This is why I love basketball!',
      ),
      JournalEntry(
        id: generateId('journal'),
        title: 'First hockey game of the season',
        dateIso: now.subtract(const Duration(days: 7)).toIso8601String().split('T')[0],
        teamId: demoTeams[2].id,
        matchId: matchWatched2Id,
        mood: 'Proud',
        body: 'Finally got to see the Thunderbolts live at the arena. The atmosphere was electric! '
            'Defense was rock solid and the goalie made some incredible saves. '
            'Great way to start the hockey season.',
      ),
      JournalEntry(
        id: generateId('journal'),
        title: 'Missed the Northern derby',
        dateIso: now.subtract(const Duration(days: 10)).toIso8601String().split('T')[0],
        teamId: demoTeams[1].id,
        matchId: matchMissedId,
        mood: 'Disappointed',
        body: 'Had to work late and missed the big derby. Heard it was an exciting game with a surprise result. '
            'Need to make sure I clear my schedule for the next one.',
      ),
      JournalEntry(
        id: generateId('journal'),
        title: 'Pre-match excitement building',
        dateIso: now.toIso8601String().split('T')[0],
        teamId: demoTeams[0].id,
        mood: 'Nervous',
        body: 'The Hawks semi-final is in 2 days and I can barely contain my excitement. '
            'This could be their year! Been watching highlight reels all week. '
            'Planning to watch with the usual crew at our favorite spot.',
      ),
      JournalEntry(
        id: generateId('journal'),
        title: 'Season reflections so far',
        dateIso: now.subtract(const Duration(days: 1)).toIso8601String().split('T')[0],
        mood: 'Neutral',
        body: 'Looking back at the season so far. Good mix of watched and planned matches. '
            'My prediction accuracy is decent. Need to catch more live games next month.',
      ),
    ];

    final demoTournaments = [
      TournamentItem(
        id: generateId('tour'),
        name: 'Spring Cup 2026',
        sport: 'Basketball',
        seasonLabel: '2026',
        favoriteParticipants: ['City Hawks', 'River Lions', 'Star Flyers'],
        isPinned: true,
        notes: 'Hawks are in the semi-finals!',
      ),
      TournamentItem(
        id: generateId('tour'),
        name: 'Premier Division',
        sport: 'Football',
        seasonLabel: '2025/26',
        favoriteParticipants: ['Northern FC', 'Blue Harbor', 'Mountain FC'],
        isPinned: true,
        notes: 'Northern currently 3rd in the table',
      ),
      TournamentItem(
        id: generateId('tour'),
        name: 'Pro Hockey League',
        sport: 'Hockey',
        seasonLabel: '2026',
        favoriteParticipants: ['Thunderbolts', 'Ice Bears'],
        isPinned: false,
      ),
      TournamentItem(
        id: generateId('tour'),
        name: 'Grand Prix Series',
        sport: 'Motorsport',
        seasonLabel: '2026',
        favoriteParticipants: ['Storm Racing'],
        isPinned: false,
        notes: 'Season just started, 8 rounds total',
      ),
    ];

    _teams = demoTeams;
    _matches = demoMatches;
    _predictions = demoPredictions;
    _journalEntries = demoJournal;
    _tournaments = demoTournaments;

    await _storage.saveTeams(_teams);
    await _storage.saveMatches(_matches);
    await _storage.savePredictions(_predictions);
    await _storage.saveJournalEntries(_journalEntries);
    await _storage.saveTournaments(_tournaments);

    notifyListeners();
  }

  // --- Stats ---

  int get totalTeams => _teams.length;
  int get plannedMatches =>
      _matches.where((m) => m.status == 'planned').length;
  int get watchedMatches =>
      _matches.where((m) => m.status == 'watched').length;
  int get totalJournalEntries => _journalEntries.length;
  int get activeTournaments => _tournaments.length;

  double get predictionAccuracy {
    final resolved =
        _predictions.where((p) => p.resultStatus != 'pending').toList();
    if (resolved.isEmpty) return 0;
    final correct =
        resolved.where((p) => p.resultStatus == 'correct').length;
    return correct / resolved.length;
  }
}
