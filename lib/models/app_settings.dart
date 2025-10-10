import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final String theme; // 'light', 'dark', 'system'
  final String language; // 'ar', 'en'
  final bool autoSave;
  final int autoSaveInterval; // بالدقائق

  const AppSettings({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.theme = 'system',
    this.language = 'ar',
    this.autoSave = true,
    this.autoSaveInterval = 5,
  });

  @override
  List<Object?> get props => [
        notificationsEnabled,
        emailNotifications,
        pushNotifications,
        theme,
        language,
        autoSave,
        autoSaveInterval
      ];

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    String? theme,
    String? language,
    bool? autoSave,
    int? autoSaveInterval,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      autoSave: autoSave ?? this.autoSave,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'theme': theme,
      'language': language,
      'autoSave': autoSave,
      'autoSaveInterval': autoSaveInterval,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      theme: json['theme'] ?? 'system',
      language: json['language'] ?? 'ar',
      autoSave: json['autoSave'] ?? true,
      autoSaveInterval: json['autoSaveInterval'] ?? 5,
    );
  }
}
