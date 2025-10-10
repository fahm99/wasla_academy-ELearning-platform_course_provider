import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/main_repository.dart';
import '../../models/index.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final MainRepository repository;

  SettingsBloc({required this.repository}) : super(SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<SettingsUpdateRequested>(_onUpdateRequested);
    on<SettingsNotificationsToggled>(_onNotificationsToggled);
    on<SettingsEmailNotificationsToggled>(_onEmailNotificationsToggled);
    on<SettingsPushNotificationsToggled>(_onPushNotificationsToggled);
    on<SettingsLanguageChanged>(_onLanguageChanged);
    on<SettingsThemeChanged>(_onThemeChanged);
    on<SettingsAutoSaveToggled>(_onAutoSaveToggled);
    on<SettingsResetRequested>(_onResetRequested);
    on<SettingsExportRequested>(_onExportRequested);
    on<SettingsImportRequested>(_onImportRequested);
  }

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(SettingsLoading());

      final settings = await repository.getSettings();

      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(const SettingsError(message: 'حدث خطأ في تحميل الإعدادات'));
    }
  }

  Future<void> _onUpdateRequested(
    SettingsUpdateRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(SettingsUpdating());

      await repository.updateSettings(event.settings);

      emit(SettingsUpdateSuccess(
        message: 'تم حفظ الإعدادات بنجاح',
        settings: event.settings,
      ));

      emit(SettingsLoaded(settings: event.settings));
    } catch (e) {
      emit(const SettingsError(message: 'حدث خطأ في حفظ الإعدادات'));
    }
  }

  Future<void> _onNotificationsToggled(
    SettingsNotificationsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;

      try {
        emit(SettingsUpdating());

        final updatedSettings = currentSettings.copyWith(
          notificationsEnabled: event.enabled,
        );

        await repository.updateSettings(updatedSettings);

        emit(SettingsUpdateSuccess(
          message:
              event.enabled ? 'تم تفعيل الإشعارات' : 'تم إلغاء تفعيل الإشعارات',
          settings: updatedSettings,
        ));

        emit(SettingsLoaded(settings: updatedSettings));
      } catch (e) {
        emit(
            const SettingsError(message: 'حدث خطأ في تحديث إعدادات الإشعارات'));
      }
    }
  }

  Future<void> _onEmailNotificationsToggled(
    SettingsEmailNotificationsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;

      try {
        emit(SettingsUpdating());

        final updatedSettings = currentSettings.copyWith(
          emailNotifications: event.enabled,
        );

        await repository.updateSettings(updatedSettings);

        emit(SettingsUpdateSuccess(
          message: event.enabled
              ? 'تم تفعيل إشعارات البريد الإلكتروني'
              : 'تم إلغاء تفعيل إشعارات البريد الإلكتروني',
          settings: updatedSettings,
        ));

        emit(SettingsLoaded(settings: updatedSettings));
      } catch (e) {
        emit(const SettingsError(
            message: 'حدث خطأ في تحديث إعدادات البريد الإلكتروني'));
      }
    }
  }

  Future<void> _onPushNotificationsToggled(
    SettingsPushNotificationsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;

      try {
        emit(SettingsUpdating());

        final updatedSettings = currentSettings.copyWith(
          pushNotifications: event.enabled,
        );

        await repository.updateSettings(updatedSettings);

        emit(SettingsUpdateSuccess(
          message: event.enabled
              ? 'تم تفعيل الإشعارات الفورية'
              : 'تم إلغاء تفعيل الإشعارات الفورية',
          settings: updatedSettings,
        ));

        emit(SettingsLoaded(settings: updatedSettings));
      } catch (e) {
        emit(const SettingsError(
            message: 'حدث خطأ في تحديث إعدادات الإشعارات الفورية'));
      }
    }
  }

  Future<void> _onLanguageChanged(
    SettingsLanguageChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;

      try {
        emit(SettingsUpdating());

        final updatedSettings = currentSettings.copyWith(
          language: event.language,
        );

        await repository.updateSettings(updatedSettings);

        emit(SettingsUpdateSuccess(
          message: 'تم تغيير اللغة بنجاح',
          settings: updatedSettings,
        ));

        emit(SettingsLoaded(settings: updatedSettings));
      } catch (e) {
        emit(const SettingsError(message: 'حدث خطأ في تغيير اللغة'));
      }
    }
  }

  Future<void> _onThemeChanged(
    SettingsThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;

      try {
        emit(SettingsUpdating());

        final updatedSettings = currentSettings.copyWith(
          theme: event.theme,
        );

        await repository.updateSettings(updatedSettings);

        emit(SettingsUpdateSuccess(
          message: 'تم تغيير المظهر بنجاح',
          settings: updatedSettings,
        ));

        emit(SettingsLoaded(settings: updatedSettings));
      } catch (e) {
        emit(const SettingsError(message: 'حدث خطأ في تغيير المظهر'));
      }
    }
  }

  Future<void> _onAutoSaveToggled(
    SettingsAutoSaveToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;

      try {
        emit(SettingsUpdating());

        final updatedSettings = currentSettings.copyWith(
          autoSave: event.enabled,
        );

        await repository.updateSettings(updatedSettings);

        emit(SettingsUpdateSuccess(
          message: event.enabled
              ? 'تم تفعيل الحفظ التلقائي'
              : 'تم إلغاء تفعيل الحفظ التلقائي',
          settings: updatedSettings,
        ));

        emit(SettingsLoaded(settings: updatedSettings));
      } catch (e) {
        emit(const SettingsError(
            message: 'حدث خطأ في تحديث إعدادات الحفظ التلقائي'));
      }
    }
  }

  Future<void> _onResetRequested(
    SettingsResetRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(SettingsResetting());

      const defaultSettings = AppSettings();
      await repository.updateSettings(defaultSettings);

      emit(const SettingsResetSuccess(settings: defaultSettings));
      emit(const SettingsLoaded(settings: defaultSettings));
    } catch (e) {
      emit(const SettingsError(message: 'حدث خطأ في إعادة تعيين الإعدادات'));
    }
  }

  Future<void> _onExportRequested(
    SettingsExportRequested event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        emit(SettingsExporting());

        // محاكاة تصدير الإعدادات
        await Future.delayed(const Duration(seconds: 2));

        final filePath =
            '/exports/settings_${DateTime.now().millisecondsSinceEpoch}.json';

        emit(SettingsExported(filePath: filePath));

        // العودة للحالة المحملة
        emit(state);
      } catch (e) {
        emit(const SettingsError(message: 'حدث خطأ في تصدير الإعدادات'));
      }
    }
  }

  Future<void> _onImportRequested(
    SettingsImportRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(SettingsImporting());

      // محاكاة استيراد الإعدادات
      await Future.delayed(const Duration(seconds: 2));

      final importedSettings = AppSettings.fromJson(event.data);
      await repository.updateSettings(importedSettings);

      emit(SettingsImportSuccess(settings: importedSettings));
      emit(SettingsLoaded(settings: importedSettings));
    } catch (e) {
      emit(const SettingsError(message: 'حدث خطأ في استيراد الإعدادات'));
    }
  }
}
