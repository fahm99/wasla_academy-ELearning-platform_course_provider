import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/main_repository.dart';
import '../../../data/models/certificate/certificate.dart';
import 'certificate_event.dart';
import 'certificate_state.dart';

class CertificateBloc extends Bloc<CertificateEvent, CertificateState> {
  final MainRepository repository;

  CertificateBloc({required this.repository}) : super(CertificateInitial()) {
    on<LoadEligibleStudents>(_onLoadEligibleStudents);
    on<LoadCourseCertificates>(_onLoadCourseCertificates);
    on<LoadCertificateSettings>(_onLoadCertificateSettings);
    on<SaveCertificateSettings>(_onSaveCertificateSettings);
    on<IssueSingleCertificate>(_onIssueSingleCertificate);
    on<IssueMultipleCertificates>(_onIssueMultipleCertificates);
    on<RevokeCertificate>(_onRevokeCertificate);
    on<RestoreCertificate>(_onRestoreCertificate);
    on<DeleteCertificate>(_onDeleteCertificate);
    on<SearchCertificates>(_onSearchCertificates);
    on<FilterCertificates>(_onFilterCertificates);
  }

  Future<void> _onLoadEligibleStudents(
    LoadEligibleStudents event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateLoading());
      final students = await repository.getEligibleStudents(event.courseId);
      emit(EligibleStudentsLoaded(students));
    } catch (e) {
      emit(CertificateError('فشل تحميل الطلاب المؤهلين: $e'));
    }
  }

  Future<void> _onLoadCourseCertificates(
    LoadCourseCertificates event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateLoading());
      final certificates =
          await repository.getCourseCertificates(event.courseId);
      emit(CourseCertificatesLoaded(
        certificates: certificates,
        filteredCertificates: certificates,
      ));
    } catch (e) {
      emit(CertificateError('فشل تحميل الشهادات: $e'));
    }
  }

  Future<void> _onLoadCertificateSettings(
    LoadCertificateSettings event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateLoading());
      final settings = await repository.getCertificateSettings(event.courseId);
      if (settings != null) {
        emit(CertificateSettingsLoaded(settings));
      } else {
        // إنشاء إعدادات افتراضية
        final defaultSettings = CertificateSettings(
          courseId: event.courseId,
          autoIssue: false,
          customColor: '#1E3A8A',
        );
        emit(CertificateSettingsLoaded(defaultSettings));
      }
    } catch (e) {
      emit(CertificateError('فشل تحميل إعدادات الشهادة: $e'));
    }
  }

  Future<void> _onSaveCertificateSettings(
    SaveCertificateSettings event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateLoading());
      final success = await repository.saveCertificateSettings(
        courseId: event.courseId,
        settings: event.settings,
      );

      if (success) {
        emit(const CertificateSettingsSaved('تم حفظ الإعدادات بنجاح'));
        // إعادة تحميل الإعدادات
        final settings =
            await repository.getCertificateSettings(event.courseId);
        if (settings != null) {
          emit(CertificateSettingsLoaded(settings));
        }
      } else {
        emit(const CertificateError('فشل حفظ الإعدادات'));
      }
    } catch (e) {
      emit(CertificateError('فشل حفظ الإعدادات: $e'));
    }
  }

  Future<void> _onIssueSingleCertificate(
    IssueSingleCertificate event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(const CertificatesIssuing(total: 1, current: 0));

      final certificate = await repository.issueCertificate(
        courseId: event.courseId,
        studentId: event.studentId,
        providerId: event.providerId,
        logoUrl: event.logoUrl,
        signatureUrl: event.signatureUrl,
        customColor: event.customColor,
        grade: event.grade,
      );

      if (certificate != null) {
        emit(const CertificatesIssued(
          successCount: 1,
          failedCount: 0,
          errors: {},
          message: 'تم إصدار الشهادة بنجاح',
        ));

        // إعادة تحميل الشهادات
        final certificates =
            await repository.getCourseCertificates(event.courseId);
        emit(CourseCertificatesLoaded(
          certificates: certificates,
          filteredCertificates: certificates,
        ));
      } else {
        emit(const CertificatesIssued(
          successCount: 0,
          failedCount: 1,
          errors: {'error': 'فشل إصدار الشهادة'},
          message: 'فشل إصدار الشهادة',
        ));
      }
    } catch (e) {
      emit(CertificateError('فشل إصدار الشهادة: $e'));
    }
  }

  Future<void> _onIssueMultipleCertificates(
    IssueMultipleCertificates event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificatesIssuing(
        total: event.studentIds.length,
        current: 0,
      ));

      final result = await repository.issueCertificates(
        courseId: event.courseId,
        studentIds: event.studentIds,
        providerId: event.providerId,
        logoUrl: event.logoUrl,
        signatureUrl: event.signatureUrl,
        customColor: event.customColor,
      );

      final successCount = result['issued'] as int;
      final failedCount = result['failed'] as int;
      final errors = result['errors'] as Map<String, String>;

      emit(CertificatesIssued(
        successCount: successCount,
        failedCount: failedCount,
        errors: errors,
        message: 'تم إصدار $successCount شهادة بنجاح',
      ));

      // إعادة تحميل الشهادات
      final certificates =
          await repository.getCourseCertificates(event.courseId);
      emit(CourseCertificatesLoaded(
        certificates: certificates,
        filteredCertificates: certificates,
      ));
    } catch (e) {
      emit(CertificateError('فشل إصدار الشهادات: $e'));
    }
  }

  Future<void> _onRevokeCertificate(
    RevokeCertificate event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      final currentState = state;
      emit(CertificateLoading());

      final success = await repository.revokeCertificate(event.certificateId);

      if (success) {
        emit(const CertificateOperationSuccess('تم إلغاء الشهادة بنجاح'));

        // إعادة تحميل الشهادات إذا كانت الحالة السابقة تحتوي على شهادات
        if (currentState is CourseCertificatesLoaded) {
          final certificate = currentState.certificates.firstWhere(
            (c) => c.id == event.certificateId,
            orElse: () => currentState.certificates.first,
          );
          final certificates =
              await repository.getCourseCertificates(certificate.courseId);
          emit(CourseCertificatesLoaded(
            certificates: certificates,
            filteredCertificates: certificates,
          ));
        }
      } else {
        emit(const CertificateError('فشل إلغاء الشهادة'));
      }
    } catch (e) {
      emit(CertificateError('فشل إلغاء الشهادة: $e'));
    }
  }

  Future<void> _onRestoreCertificate(
    RestoreCertificate event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      final currentState = state;
      emit(CertificateLoading());

      final success = await repository.restoreCertificate(event.certificateId);

      if (success) {
        emit(const CertificateOperationSuccess('تم استعادة الشهادة بنجاح'));

        // إعادة تحميل الشهادات إذا كانت الحالة السابقة تحتوي على شهادات
        if (currentState is CourseCertificatesLoaded) {
          final certificate = currentState.certificates.firstWhere(
            (c) => c.id == event.certificateId,
            orElse: () => currentState.certificates.first,
          );
          final certificates =
              await repository.getCourseCertificates(certificate.courseId);
          emit(CourseCertificatesLoaded(
            certificates: certificates,
            filteredCertificates: certificates,
          ));
        }
      } else {
        emit(const CertificateError('فشل استعادة الشهادة'));
      }
    } catch (e) {
      emit(CertificateError('فشل استعادة الشهادة: $e'));
    }
  }

  Future<void> _onDeleteCertificate(
    DeleteCertificate event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      final currentState = state;
      emit(CertificateLoading());

      final success = await repository.deleteCertificate(event.certificateId);

      if (success) {
        emit(const CertificateOperationSuccess('تم حذف الشهادة بنجاح'));

        // إعادة تحميل الشهادات إذا كانت الحالة السابقة تحتوي على شهادات
        if (currentState is CourseCertificatesLoaded) {
          final certificate = currentState.certificates.firstWhere(
            (c) => c.id == event.certificateId,
            orElse: () => currentState.certificates.first,
          );
          final certificates =
              await repository.getCourseCertificates(certificate.courseId);
          emit(CourseCertificatesLoaded(
            certificates: certificates,
            filteredCertificates: certificates,
          ));
        }
      } else {
        emit(const CertificateError('فشل حذف الشهادة'));
      }
    } catch (e) {
      emit(CertificateError('فشل حذف الشهادة: $e'));
    }
  }

  Future<void> _onSearchCertificates(
    SearchCertificates event,
    Emitter<CertificateState> emit,
  ) async {
    if (state is! CourseCertificatesLoaded) return;

    final currentState = state as CourseCertificatesLoaded;
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      emit(currentState.copyWith(
        filteredCertificates: currentState.certificates,
        clearSearch: true,
      ));
      return;
    }

    final filtered = currentState.certificates.where((cert) {
      return cert.studentName.toLowerCase().contains(query) ||
          cert.studentEmail.toLowerCase().contains(query) ||
          cert.certificateNumber.toLowerCase().contains(query);
    }).toList();

    // تطبيق الفلتر إذا كان موجوداً
    final finalFiltered = currentState.statusFilter != null
        ? filtered
            .where((cert) => cert.status == currentState.statusFilter)
            .toList()
        : filtered;

    emit(currentState.copyWith(
      filteredCertificates: finalFiltered,
      searchQuery: event.query,
    ));
  }

  Future<void> _onFilterCertificates(
    FilterCertificates event,
    Emitter<CertificateState> emit,
  ) async {
    if (state is! CourseCertificatesLoaded) return;

    final currentState = state as CourseCertificatesLoaded;

    if (event.status == null) {
      emit(currentState.copyWith(
        filteredCertificates: currentState.certificates,
        clearFilter: true,
      ));
      return;
    }

    var filtered = currentState.certificates
        .where((cert) => cert.status == event.status)
        .toList();

    // تطبيق البحث إذا كان موجوداً
    if (currentState.searchQuery != null &&
        currentState.searchQuery!.isNotEmpty) {
      final query = currentState.searchQuery!.toLowerCase();
      filtered = filtered.where((cert) {
        return cert.studentName.toLowerCase().contains(query) ||
            cert.studentEmail.toLowerCase().contains(query) ||
            cert.certificateNumber.toLowerCase().contains(query);
      }).toList();
    }

    emit(currentState.copyWith(
      filteredCertificates: filtered,
      statusFilter: event.status,
    ));
  }
}
