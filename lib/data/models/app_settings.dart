import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String id;
  final String userId;
  final String theme; // 'light', 'dark'
  final String language; // 'ar', 'en'
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool autoSave;
  final Map<String, dynamic>? settingsData;
  final DateTime updatedAt;

  const AppSettings({
    required this.id,
    required this.userId,
    this.theme = 'light',
    this.language = 'ar',
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.autoSave = true,
    this.settingsData,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        theme,
        language,
        notificationsEnabled,
        emailNotifications,
        pushNotifications,
        autoSave,
        settingsData,
        updatedAt,
      ];

  AppSettings copyWith({
    String? id,
    String? userId,
    String? theme,
    String? language,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? autoSave,
    Map<String, dynamic>? settingsData,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      autoSave: autoSave ?? this.autoSave,
      settingsData: settingsData ?? this.settingsData,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'theme': theme,
      'language': language,
      'notifications_enabled': notificationsEnabled,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'auto_save': autoSave,
      'settings_data': settingsData,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      theme: json['theme'] ?? 'light',
      language: json['language'] ?? 'ar',
      notificationsEnabled: json['notifications_enabled'] ?? true,
      emailNotifications: json['email_notifications'] ?? true,
      pushNotifications: json['push_notifications'] ?? true,
      autoSave: json['auto_save'] ?? true,
      settingsData: json['settings_data'],
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
