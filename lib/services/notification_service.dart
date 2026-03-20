import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  Future<void> init() async {
    debugPrint('NotificationService: init (placeholder)');
  }

  Future<void> scheduleMatchReminder({
    required String matchId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    debugPrint(
      'NotificationService: schedule reminder for $matchId at $scheduledDate',
    );
  }

  Future<void> cancelReminder(String matchId) async {
    debugPrint('NotificationService: cancel reminder for $matchId');
  }

  Future<void> cancelAll() async {
    debugPrint('NotificationService: cancel all reminders');
  }
}
