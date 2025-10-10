import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/main_repository.dart';
import '../../models/index.dart';
import 'certificate_event.dart';
import 'certificate_state.dart';

class CertificateBloc extends Bloc<CertificateEvent, CertificateState> {
  final MainRepository repository;

  CertificateBloc({required this.repository}) : super(CertificateInitial()) {
    on<CertificateLoadRequested>(_onLoadRequested);
    on<CertificateIssueRequested>(_onIssueRequested);
    on<CertificateRevokeRequested>(_onRevokeRequested);
    on<CertificateRestoreRequested>(_onRestoreRequested);
    on<CertificateSearchRequested>(_onSearchRequested);
    on<CertificateFilterRequested>(_onFilterRequested);
    on<CertificateClearFilters>(_onClearFilters);
    on<CertificateSortRequested>(_onSortRequested);
    on<CertificateDownloadRequested>(_onDownloadRequested);
    on<CertificateShareRequested>(_onShareRequested);
    on<CertificateVerifyRequested>(_onVerifyRequested);
  }

  Future<void> _onLoadRequested(
    CertificateLoadRequested event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateLoading());

      final certificates = await repository.getCertificates();

      emit(CertificateLoaded(
        certificates: certificates,
        filteredCertificates: certificates,
      ));
    } catch (e) {
      emit(const CertificateError(message: 'حدث خطأ في تحميل الشهادات'));
    }
  }

  Future<void> _onIssueRequested(
    CertificateIssueRequested event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateIssuing());

      // الحصول على بيانات الطالب والدورة
      final student = await repository.getStudentById(event.studentId);
      final course = await repository.getCourseById(event.courseId);

      if (student == null) {
        emit(const CertificateError(message: 'لم يتم العثور على الطالب'));
        return;
      }

      if (course == null) {
        emit(const CertificateError(message: 'لم يتم العثور على الدورة'));
        return;
      }

      // التحقق من أن الطالب مسجل في الدورة
      if (!student.enrolledCourses.contains(event.courseId)) {
        emit(const CertificateError(message: 'الطالب غير مسجل في هذه الدورة'));
        return;
      }

      // التحقق من عدم وجود شهادة مسبقة
      final existingCertificates = await repository.getCertificates();
      final existingCertificate = existingCertificates
          .where((cert) =>
              cert.studentId == event.studentId &&
              cert.courseId == event.courseId)
          .firstOrNull;

      if (existingCertificate != null) {
        emit(const CertificateError(
            message: 'تم إصدار شهادة لهذا الطالب في هذه الدورة مسبقاً'));
        return;
      }

      // إنشاء الشهادة
      final certificate = Certificate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: event.studentId,
        studentName: student.name,
        courseId: event.courseId,
        courseName: event.courseTitle,
        providerId: course.providerId,
        providerName: course.providerName,
        issuedAt: DateTime.now(),
        certificateUrl:
            'https://example.com/certificates/${DateTime.now().millisecondsSinceEpoch}.pdf',
        status: CertificateStatus.active,
      );

      await repository.addCertificate(certificate);

      // تحديث بيانات الطالب لإضافة الشهادة
      final updatedStudent = student.copyWith(
        certificateIds: [...student.certificateIds, certificate.id],
      );
      await repository.updateStudent(updatedStudent);

      final certificates = await repository.getCertificates();

      emit(CertificateOperationSuccess(
        message: 'تم إصدار الشهادة بنجاح',
        certificates: certificates,
      ));

      emit(CertificateLoaded(
        certificates: certificates,
        filteredCertificates: certificates,
      ));
    } catch (e) {
      emit(const CertificateError(message: 'حدث خطأ في إصدار الشهادة'));
    }
  }

  Future<void> _onRevokeRequested(
    CertificateRevokeRequested event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateRevoking());

      final certificate =
          await repository.getCertificateById(event.certificateId);
      if (certificate != null) {
        final updatedCertificate =
            certificate.copyWith(status: CertificateStatus.revoked);
        await repository.updateCertificate(updatedCertificate);

        final certificates = await repository.getCertificates();

        emit(CertificateOperationSuccess(
          message: 'تم إلغاء الشهادة بنجاح',
          certificates: certificates,
        ));

        emit(CertificateLoaded(
          certificates: certificates,
          filteredCertificates: certificates,
        ));
      } else {
        emit(const CertificateError(message: 'لم يتم العثور على الشهادة'));
      }
    } catch (e) {
      emit(const CertificateError(message: 'حدث خطأ في إلغاء الشهادة'));
    }
  }

  Future<void> _onRestoreRequested(
    CertificateRestoreRequested event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateRevoking());

      final certificate =
          await repository.getCertificateById(event.certificateId);
      if (certificate != null) {
        final updatedCertificate =
            certificate.copyWith(status: CertificateStatus.active);
        await repository.updateCertificate(updatedCertificate);

        final certificates = await repository.getCertificates();

        emit(CertificateOperationSuccess(
          message: 'تم استعادة الشهادة بنجاح',
          certificates: certificates,
        ));

        emit(CertificateLoaded(
          certificates: certificates,
          filteredCertificates: certificates,
        ));
      } else {
        emit(const CertificateError(message: 'لم يتم العثور على الشهادة'));
      }
    } catch (e) {
      emit(const CertificateError(message: 'حدث خطأ في استعادة الشهادة'));
    }
  }

  Future<void> _onSearchRequested(
    CertificateSearchRequested event,
    Emitter<CertificateState> emit,
  ) async {
    if (state is CertificateLoaded) {
      final currentState = state as CertificateLoaded;

      try {
        List<Certificate> filteredCertificates;

        if (event.query.isEmpty) {
          filteredCertificates = currentState.certificates;
        } else {
          filteredCertificates = currentState.certificates.where((certificate) {
            return certificate.studentName
                    .toLowerCase()
                    .contains(event.query.toLowerCase()) ||
                certificate.courseName
                    .toLowerCase()
                    .contains(event.query.toLowerCase()) ||
                certificate.id
                    .toLowerCase()
                    .contains(event.query.toLowerCase());
          }).toList();
        }

        // تطبيق الفلاتر الحالية
        filteredCertificates = _applyFilters(
          filteredCertificates,
          currentState.statusFilter,
          currentState.courseFilter,
          currentState.startDateFilter,
          currentState.endDateFilter,
        );

        // تطبيق الترتيب الحالي
        if (currentState.sortBy != null) {
          filteredCertificates = _sortCertificates(
            filteredCertificates,
            currentState.sortBy!,
            currentState.sortAscending,
          );
        }

        emit(currentState.copyWith(
          filteredCertificates: filteredCertificates,
          searchQuery: event.query,
        ));
      } catch (e) {
        emit(const CertificateError(message: 'حدث خطأ في البحث'));
      }
    }
  }

  Future<void> _onFilterRequested(
    CertificateFilterRequested event,
    Emitter<CertificateState> emit,
  ) async {
    if (state is CertificateLoaded) {
      final currentState = state as CertificateLoaded;

      try {
        List<Certificate> filteredCertificates = currentState.certificates;

        // تطبيق البحث أولاً
        if (currentState.searchQuery != null &&
            currentState.searchQuery!.isNotEmpty) {
          filteredCertificates = filteredCertificates.where((certificate) {
            return certificate.studentName
                    .toLowerCase()
                    .contains(currentState.searchQuery!.toLowerCase()) ||
                certificate.courseName
                    .toLowerCase()
                    .contains(currentState.searchQuery!.toLowerCase()) ||
                certificate.id
                    .toLowerCase()
                    .contains(currentState.searchQuery!.toLowerCase());
          }).toList();
        }

        // تطبيق الفلاتر
        filteredCertificates = _applyFilters(
          filteredCertificates,
          event.status,
          event.courseId,
          event.startDate,
          event.endDate,
        );

        // تطبيق الترتيب الحالي
        if (currentState.sortBy != null) {
          filteredCertificates = _sortCertificates(
            filteredCertificates,
            currentState.sortBy!,
            currentState.sortAscending,
          );
        }

        emit(currentState.copyWith(
          filteredCertificates: filteredCertificates,
          statusFilter: event.status,
          courseFilter: event.courseId,
          startDateFilter: event.startDate,
          endDateFilter: event.endDate,
        ));
      } catch (e) {
        emit(const CertificateError(message: 'حدث خطأ في تطبيق الفلاتر'));
      }
    }
  }

  Future<void> _onClearFilters(
    CertificateClearFilters event,
    Emitter<CertificateState> emit,
  ) async {
    if (state is CertificateLoaded) {
      final currentState = state as CertificateLoaded;

      emit(currentState.copyWith(
        filteredCertificates: currentState.certificates,
        searchQuery: null,
        statusFilter: null,
        courseFilter: null,
        startDateFilter: null,
        endDateFilter: null,
        sortBy: null,
        sortAscending: true,
      ));
    }
  }

  Future<void> _onSortRequested(
    CertificateSortRequested event,
    Emitter<CertificateState> emit,
  ) async {
    if (state is CertificateLoaded) {
      final currentState = state as CertificateLoaded;

      try {
        final sortedCertificates = _sortCertificates(
          currentState.filteredCertificates,
          event.sortBy,
          event.ascending,
        );

        emit(currentState.copyWith(
          filteredCertificates: sortedCertificates,
          sortBy: event.sortBy,
          sortAscending: event.ascending,
        ));
      } catch (e) {
        emit(const CertificateError(message: 'حدث خطأ في ترتيب الشهادات'));
      }
    }
  }

  Future<void> _onDownloadRequested(
    CertificateDownloadRequested event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateDownloading());

      final certificate =
          await repository.getCertificateById(event.certificateId);
      if (certificate != null) {
        // محاكاة تحميل الشهادة
        await Future.delayed(const Duration(seconds: 2));

        // في التطبيق الحقيقي، سيتم تحميل الملف الفعلي
        final filePath = '/downloads/certificate_${certificate.id}.pdf';

        emit(CertificateDownloaded(filePath: filePath));
      } else {
        emit(const CertificateError(message: 'لم يتم العثور على الشهادة'));
      }
    } catch (e) {
      emit(const CertificateError(message: 'حدث خطأ في تحميل الشهادة'));
    }
  }

  Future<void> _onShareRequested(
    CertificateShareRequested event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateSharing());

      final certificate =
          await repository.getCertificateById(event.certificateId);
      if (certificate != null) {
        // محاكاة إنشاء رابط المشاركة
        await Future.delayed(const Duration(seconds: 1));

        final shareUrl =
            'https://wasla.com/certificates/verify/${certificate.id}';

        emit(CertificateShared(shareUrl: shareUrl));
      } else {
        emit(const CertificateError(message: 'لم يتم العثور على الشهادة'));
      }
    } catch (e) {
      emit(const CertificateError(message: 'حدث خطأ في مشاركة الشهادة'));
    }
  }

  Future<void> _onVerifyRequested(
    CertificateVerifyRequested event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateVerifying());

      final certificate =
          await repository.getCertificateById(event.certificateId);
      if (certificate != null) {
        // محاكاة التحقق من صحة الشهادة
        await Future.delayed(const Duration(seconds: 2));

        final isValid = certificate.status == CertificateStatus.active;

        emit(CertificateVerified(
          certificate: certificate,
          isValid: isValid,
        ));
      } else {
        emit(const CertificateError(message: 'لم يتم العثور على الشهادة'));
      }
    } catch (e) {
      emit(const CertificateError(message: 'حدث خطأ في التحقق من الشهادة'));
    }
  }

  List<Certificate> _applyFilters(
    List<Certificate> certificates,
    CertificateStatus? status,
    String? courseId,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return certificates.where((certificate) {
      if (status != null && certificate.status != status) return false;
      if (courseId != null && certificate.courseId != courseId) return false;
      if (startDate != null && certificate.issuedAt.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && certificate.issuedAt.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Certificate> _sortCertificates(
    List<Certificate> certificates,
    String sortBy,
    bool ascending,
  ) {
    final sortedCertificates = List<Certificate>.from(certificates);

    switch (sortBy) {
      case 'studentName':
        sortedCertificates.sort((a, b) => ascending
            ? a.studentName.compareTo(b.studentName)
            : b.studentName.compareTo(a.studentName));
        break;
      case 'courseName':
        sortedCertificates.sort((a, b) => ascending
            ? a.courseName.compareTo(b.courseName)
            : b.courseName.compareTo(a.courseName));
        break;
      case 'issuedAt':
        sortedCertificates.sort((a, b) => ascending
            ? a.issuedAt.compareTo(b.issuedAt)
            : b.issuedAt.compareTo(a.issuedAt));
        break;
    }

    return sortedCertificates;
  }
}
