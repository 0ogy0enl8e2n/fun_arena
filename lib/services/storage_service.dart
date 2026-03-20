import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/team_item.dart';
import '../models/match_plan.dart';
import '../models/prediction_item.dart';
import '../models/journal_entry.dart';
import '../models/tournament_item.dart';

class StorageService {
  static const _keyOnboardingCompleted = 'onboarding_completed';
  static const _keyProfileData = 'profile_data_json';
  static const _keyTeamsList = 'teams_list_json';
  static const _keyMatchesList = 'matches_list_json';
  static const _keyPredictionsList = 'predictions_list_json';
  static const _keyJournalList = 'journal_list_json';
  static const _keyTournamentsList = 'tournaments_list_json';
  static const _keyThemeMode = 'theme_mode';
  static const _keySchemaVersion = 'storage_schema_version';
  static const _currentSchemaVersion = 1;

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _migrateIfNeeded();
  }

  void _migrateIfNeeded() {
    final version = _prefs.getInt(_keySchemaVersion) ?? 0;
    if (version < _currentSchemaVersion) {
      _prefs.setInt(_keySchemaVersion, _currentSchemaVersion);
    }
  }

  bool get onboardingCompleted =>
      _prefs.getBool(_keyOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(_keyOnboardingCompleted, value);

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(_keyThemeMode, mode);

  UserProfile getProfile() {
    final raw = _prefs.getString(_keyProfileData);
    if (raw == null) return const UserProfile();
    try {
      return UserProfile.fromJson(
          json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserProfile();
    }
  }

  Future<void> saveProfile(UserProfile profile) =>
      _prefs.setString(_keyProfileData, json.encode(profile.toJson()));

  List<TeamItem> getTeams() => _decodeList(
        _keyTeamsList,
        (m) => TeamItem.fromJson(m),
      );

  Future<void> saveTeams(List<TeamItem> items) =>
      _saveList(_keyTeamsList, items);

  List<MatchPlan> getMatches() => _decodeList(
        _keyMatchesList,
        (m) => MatchPlan.fromJson(m),
      );

  Future<void> saveMatches(List<MatchPlan> items) =>
      _saveList(_keyMatchesList, items);

  List<PredictionItem> getPredictions() => _decodeList(
        _keyPredictionsList,
        (m) => PredictionItem.fromJson(m),
      );

  Future<void> savePredictions(List<PredictionItem> items) =>
      _saveList(_keyPredictionsList, items);

  List<JournalEntry> getJournalEntries() => _decodeList(
        _keyJournalList,
        (m) => JournalEntry.fromJson(m),
      );

  Future<void> saveJournalEntries(List<JournalEntry> items) =>
      _saveList(_keyJournalList, items);

  List<TournamentItem> getTournaments() => _decodeList(
        _keyTournamentsList,
        (m) => TournamentItem.fromJson(m),
      );

  Future<void> saveTournaments(List<TournamentItem> items) =>
      _saveList(_keyTournamentsList, items);

  Map<String, dynamic> exportAll() {
    return {
      'schema_version': _currentSchemaVersion,
      'profile': getProfile().toJson(),
      'teams': getTeams().map((e) => e.toJson()).toList(),
      'matches': getMatches().map((e) => e.toJson()).toList(),
      'predictions': getPredictions().map((e) => e.toJson()).toList(),
      'journal': getJournalEntries().map((e) => e.toJson()).toList(),
      'tournaments': getTournaments().map((e) => e.toJson()).toList(),
    };
  }

  Future<void> importAll(Map<String, dynamic> data) async {
    if (data['profile'] != null) {
      await saveProfile(
          UserProfile.fromJson(data['profile'] as Map<String, dynamic>));
    }
    if (data['teams'] != null) {
      await saveTeams((data['teams'] as List)
          .map((e) => TeamItem.fromJson(e as Map<String, dynamic>))
          .toList());
    }
    if (data['matches'] != null) {
      await saveMatches((data['matches'] as List)
          .map((e) => MatchPlan.fromJson(e as Map<String, dynamic>))
          .toList());
    }
    if (data['predictions'] != null) {
      await savePredictions((data['predictions'] as List)
          .map(
              (e) => PredictionItem.fromJson(e as Map<String, dynamic>))
          .toList());
    }
    if (data['journal'] != null) {
      await saveJournalEntries((data['journal'] as List)
          .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
          .toList());
    }
    if (data['tournaments'] != null) {
      await saveTournaments((data['tournaments'] as List)
          .map(
              (e) => TournamentItem.fromJson(e as Map<String, dynamic>))
          .toList());
    }
  }

  Future<void> clearAll() async {
    await _prefs.remove(_keyProfileData);
    await _prefs.remove(_keyTeamsList);
    await _prefs.remove(_keyMatchesList);
    await _prefs.remove(_keyPredictionsList);
    await _prefs.remove(_keyJournalList);
    await _prefs.remove(_keyTournamentsList);
    await _prefs.remove(_keyOnboardingCompleted);
  }

  List<T> _decodeList<T>(
      String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List;
      return list
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveList<T>(String key, List<T> items) {
    final encoded = json.encode(
      items.map((e) => (e as dynamic).toJson()).toList(),
    );
    return _prefs.setString(key, encoded);
  }
}
