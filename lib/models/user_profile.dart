class UserProfile {
  final String nickname;
  final List<String> favoriteSports;
  final bool defaultRemindersEnabled;
  final String themeMode;

  const UserProfile({
    this.nickname = 'Fan',
    this.favoriteSports = const [],
    this.defaultRemindersEnabled = true,
    this.themeMode = 'system',
  });

  UserProfile copyWith({
    String? nickname,
    List<String>? favoriteSports,
    bool? defaultRemindersEnabled,
    String? themeMode,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      favoriteSports: favoriteSports ?? this.favoriteSports,
      defaultRemindersEnabled:
          defaultRemindersEnabled ?? this.defaultRemindersEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'favoriteSports': favoriteSports,
        'defaultRemindersEnabled': defaultRemindersEnabled,
        'themeMode': themeMode,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] as String? ?? 'Fan',
      favoriteSports:
          List<String>.from(json['favoriteSports'] as List? ?? []),
      defaultRemindersEnabled:
          json['defaultRemindersEnabled'] as bool? ?? true,
      themeMode: json['themeMode'] as String? ?? 'system',
    );
  }
}
