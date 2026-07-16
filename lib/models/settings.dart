/// Modèle Settings pour REVOSILIUM v3
/// Simple classe de configuration UI
class AppSettings {
  bool ghostMode;
  bool autoWipe;
  bool vibration;
  bool notifications;
  int smsDelay;
  String language;
  String blackBoxPassword;

  AppSettings({
    this.ghostMode = false,
    this.autoWipe = true,
    this.vibration = true,
    this.notifications = true,
    this.smsDelay = 500,
    this.language = 'fr',
    this.blackBoxPassword = 'revosilium2024',
  });

  AppSettings copyWith({
    bool? ghostMode,
    bool? autoWipe,
    bool? vibration,
    bool? notifications,
    int? smsDelay,
    String? language,
    String? blackBoxPassword,
  }) {
    return AppSettings(
      ghostMode: ghostMode ?? this.ghostMode,
      autoWipe: autoWipe ?? this.autoWipe,
      vibration: vibration ?? this.vibration,
      notifications: notifications ?? this.notifications,
      smsDelay: smsDelay ?? this.smsDelay,
      language: language ?? this.language,
      blackBoxPassword: blackBoxPassword ?? this.blackBoxPassword,
    );
  }

  Map<String, dynamic> toJson() => {
        'ghostMode': ghostMode,
        'autoWipe': autoWipe,
        'vibration': vibration,
        'notifications': notifications,
        'smsDelay': smsDelay,
        'language': language,
        'blackBoxPassword': blackBoxPassword,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        ghostMode: json['ghostMode'] ?? false,
        autoWipe: json['autoWipe'] ?? true,
        vibration: json['vibration'] ?? true,
        notifications: json['notifications'] ?? true,
        smsDelay: json['smsDelay'] ?? 500,
        language: json['language'] ?? 'fr',
        blackBoxPassword:
            json['blackBoxPassword'] ?? 'revosilium2024',
      );
}
