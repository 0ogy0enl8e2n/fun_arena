import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const List<String> sports = [
    'Football',
    'Basketball',
    'Hockey',
    'Tennis',
    'Volleyball',
    'Baseball',
    'Motorsport',
    'Esports',
    'Other',
  ];

  static const List<String> moods = [
    'Excited',
    'Proud',
    'Nervous',
    'Disappointed',
    'Neutral',
  ];

  static const List<String> matchStatuses = [
    'planned',
    'watched',
    'missed',
  ];

  static const List<String> predictionStatuses = [
    'pending',
    'correct',
    'incorrect',
  ];

  static const Map<String, int> reminderOffsets = {
    '15 min': 15,
    '1 hour': 60,
    '3 hours': 180,
    '1 day': 1440,
  };

  static IconData sportIcon(String sport) {
    return switch (sport) {
      'Football' => Icons.sports_soccer,
      'Basketball' => Icons.sports_basketball,
      'Hockey' => Icons.sports_hockey,
      'Tennis' => Icons.sports_tennis,
      'Volleyball' => Icons.sports_volleyball,
      'Baseball' => Icons.sports_baseball,
      'Motorsport' => Icons.sports_motorsports,
      'Esports' => Icons.sports_esports,
      _ => Icons.sports,
    };
  }

  static IconData moodIcon(String mood) {
    return switch (mood) {
      'Excited' => Icons.celebration,
      'Proud' => Icons.emoji_events,
      'Nervous' => Icons.psychology,
      'Disappointed' => Icons.sentiment_dissatisfied,
      'Neutral' => Icons.sentiment_neutral,
      _ => Icons.circle,
    };
  }

  static Color moodColor(String mood) {
    return switch (mood) {
      'Excited' => const Color(0xFFFF7A00),
      'Proud' => const Color(0xFF18A957),
      'Nervous' => const Color(0xFFF4A100),
      'Disappointed' => const Color(0xFFD64545),
      'Neutral' => const Color(0xFF667085),
      _ => const Color(0xFF667085),
    };
  }

  static String matchStatusLabel(String status) {
    return switch (status) {
      'planned' => 'Planned',
      'watched' => 'Watched',
      'missed' => 'Missed',
      _ => status,
    };
  }

  static Color matchStatusColor(String status) {
    return switch (status) {
      'planned' => const Color(0xFF1E6BFF),
      'watched' => const Color(0xFF18A957),
      'missed' => const Color(0xFFD64545),
      _ => const Color(0xFF667085),
    };
  }

  static String predictionStatusLabel(String status) {
    return switch (status) {
      'pending' => 'Pending',
      'correct' => 'Correct',
      'incorrect' => 'Incorrect',
      _ => status,
    };
  }

  static Color predictionStatusColor(String status) {
    return switch (status) {
      'pending' => const Color(0xFFF4A100),
      'correct' => const Color(0xFF18A957),
      'incorrect' => const Color(0xFFD64545),
      _ => const Color(0xFF667085),
    };
  }
}
