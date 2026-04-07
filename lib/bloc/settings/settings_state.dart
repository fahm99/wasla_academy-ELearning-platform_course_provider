import 'package:equatable/equatable.dart';
import '../../data/models/index.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;

  const SettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SettingsUpdating extends SettingsState {}

class SettingsUpdateSuccess extends SettingsState {
  final String message;
  final AppSettings settings;

  const SettingsUpdateSuccess({
    required this.message,
    required this.settings,
  });

  @override
  List<Object?> get props => [message, settings];
}

class SettingsResetting extends SettingsState {}

class SettingsResetSuccess extends SettingsState {
  final AppSettings settings;

  const SettingsResetSuccess({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class SettingsExporting extends SettingsState {}

class SettingsExported extends SettingsState {
  final String filePath;

  const SettingsExported({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class SettingsImporting extends SettingsState {}

class SettingsImportSuccess extends SettingsState {
  final AppSettings settings;

  const SettingsImportSuccess({required this.settings});

  @override
  List<Object?> get props => [settings];
}
