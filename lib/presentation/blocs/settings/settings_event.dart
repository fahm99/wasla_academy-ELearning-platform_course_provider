import 'package:course_provider/data/models/app_settings.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {}

class SettingsUpdateRequested extends SettingsEvent {
  final AppSettings settings;

  const SettingsUpdateRequested({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class SettingsNotificationsToggled extends SettingsEvent {
  final bool enabled;

  const SettingsNotificationsToggled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class SettingsEmailNotificationsToggled extends SettingsEvent {
  final bool enabled;

  const SettingsEmailNotificationsToggled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class SettingsPushNotificationsToggled extends SettingsEvent {
  final bool enabled;

  const SettingsPushNotificationsToggled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class SettingsLanguageChanged extends SettingsEvent {
  final String language;

  const SettingsLanguageChanged({required this.language});

  @override
  List<Object?> get props => [language];
}

class SettingsThemeChanged extends SettingsEvent {
  final String theme;

  const SettingsThemeChanged({required this.theme});

  @override
  List<Object?> get props => [theme];
}

class SettingsAutoSaveToggled extends SettingsEvent {
  final bool enabled;

  const SettingsAutoSaveToggled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class SettingsResetRequested extends SettingsEvent {}

class SettingsExportRequested extends SettingsEvent {}

class SettingsImportRequested extends SettingsEvent {
  final Map<String, dynamic> data;

  const SettingsImportRequested({required this.data});

  @override
  List<Object?> get props => [data];
}
