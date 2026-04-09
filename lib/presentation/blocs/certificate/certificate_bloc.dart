import 'package:course_provider/data/models/certificate.dart';
import 'package:course_provider/data/repositories/main_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      final certificatesData = await repository.getCertificates();

      // تحويل Map إلى Certificate objects
      final certificates = certificatesData.map((data) {
        return Certificate(
          id: data['id'] ?? '',
          courseId: data['course_id'] ?? '',
          studentId: data['student_id'] ?? '',
          providerId: data['provider_id'] ?? '',
          certificateNumber: data['certificate_number'] ?? '',
          issueDate: data['issue_date'] != null
              ? DateTime.parse(data['issue_date'])
              : DateTime.now(),
          expiryDate: data['expiry_date'] != null
              ? DateTime.parse(data['expiry_date'])
              : null,
          certificateUrl: data['certificate_url'],
          status: data['status'] == 'revoked'
              ? CertificateStatus.revoked
              : CertificateStatus.issued,
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
        );
      }).toList();

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

      final course = await repository.getCourseById(event.courseId);
      if (course == null) {
        emit(const CertificateError(message: 'لم يتم العثور على الدورة'));
        return;
      }

      // إصدار الشهادة عبر Repository
      final certificateData = await repository.issueCertificate(
        courseId: event.courseId,
        studentId: event.studentId,
        providerId: course.providerId,
      );

      if (certificateData.isEmpty) {
        emit(const CertificateError(message: 'حدث خطأ في إصدار الشهادة'));
        return;
      }

      // إعادة تحميل الشهادات
      final certificatesData = await repository.getCertificates();
      final certificates = certificatesData.map((data) {
        return Certificate(
          id: data['id'] ?? '',
          courseId: data['course_id'] ?? '',
          studentId: data['student_id'] ?? '',
          providerId: data['provider_id'] ?? '',
          certificateNumber: data['certificate_number'] ?? '',
          issueDate: data['issue_date'] != null
              ? DateTime.parse(data['issue_date'])
              : DateTime.now(),
          expiryDate: data['expiry_date'] != null
              ? DateTime.parse(data['expiry_date'])
              : null,
          certificateUrl: data['certificate_url'],
          status: data['status'] == 'revoked'
              ? CertificateStatus.revoked
              : CertificateStatus.issued,
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
        );
      }).toList();

      emit(CertificateOperationSuccess(
        message: 'تم إصدار الشهادة بنجاح',
        certificates: certificates,
      ));
      emit(CertificateLoaded(
        certificates: certificates,
        filteredCertificates: certificates,
      ));
    } catch (e) {
      emit(CertificateError(message: 'حدث خطأ في إصدار الشهادة: $e'));
    }
  }

  Future<void> _onRevokeRequested(
    CertificateRevokeRequested event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateRevoking());

      // إلغاء الشهادة
      await repository.revokeCertificate(event.certificateId);

      // إعادة تحميل الشهادات
      final certificatesData = await repository.getCertificates();
      final certificates = certificatesData.map((data) {
        return Certificate(
          id: data['id'] ?? '',
          courseId: data['course_id'] ?? '',
          studentId: data['student_id'] ?? '',
          providerId: data['provider_id'] ?? '',
          certificateNumber: data['certificate_number'] ?? '',
          issueDate: data['issue_date'] != null
              ? DateTime.parse(data['issue_date'])
              : DateTime.now(),
          expiryDate: data['expiry_date'] != null
              ? DateTime.parse(data['expiry_date'])
              : null,
          certificateUrl: data['certificate_url'],
          status: data['status'] == 'revoked'
              ? CertificateStatus.revoked
              : CertificateStatus.issued,
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
        );
      }).toList();

      emit(CertificateOperationSuccess(
        message: 'تم إلغاء الشهادة بنجاح',
        certificates: certificates,
      ));
      emit(CertificateLoaded(
        certificates: certificates,
        filteredCertificates: certificates,
      ));
    } catch (e) {
      emit(CertificateError(message: 'حدث خطأ في إلغاء الشهادة: $e'));
    }
  }

  Future<void> _onRestoreRequested(
    CertificateRestoreRequested event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateRevoking());

      // استعادة الشهادة
      await repository.restoreCertificate(event.certificateId);

      // إعادة تحميل الشهادات
      final certificatesData = await repository.getCertificates();
      final certificates = certificatesData.map((data) {
        return Certificate(
          id: data['id'] ?? '',
          courseId: data['course_id'] ?? '',
          studentId: data['student_id'] ?? '',
          providerId: data['provider_id'] ?? '',
          certificateNumber: data['certificate_number'] ?? '',
          issueDate: data['issue_date'] != null
              ? DateTime.parse(data['issue_date'])
              : DateTime.now(),
          expiryDate: data['expiry_date'] != null
              ? DateTime.parse(data['expiry_date'])
              : null,
          certificateUrl: data['certificate_url'],
          status: data['status'] == 'revoked'
              ? CertificateStatus.revoked
              : CertificateStatus.issued,
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
        );
      }).toList();

      emit(CertificateOperationSuccess(
        message: 'تم استعادة الشهادة بنجاح',
        certificates: certificates,
      ));
      emit(CertificateLoaded(
        certificates: certificates,
        filteredCertificates: certificates,
      ));
    } catch (e) {
      emit(CertificateError(message: 'حدث خطأ في استعادة الشهادة: $e'));
    }
  }

  Future<void> _onSearchRequested(
    CertificateSearchRequested event,
    Emitter<CertificateState> emit,
  ) async {
    if (state is! CertificateLoaded) return;
    final currentState = state as CertificateLoaded;
    try {
      List<Certificate> filtered = event.query.isEmpty
          ? currentState.certificates
          : currentState.certificates
              .where((cert) =>
                  cert.studentId.contains(event.query) ||
                  cert.courseId.contains(event.query) ||
                  cert.certificateNumber
                      .toLowerCase()
                      .contains(event.query.toLowerCase()))
              .toList();

      filtered = _applyFilters(
        filtered,
        currentState.statusFilter,
        currentState.courseFilter,
        currentState.startDateFilter,
        currentState.endDateFilter,
      );

      if (currentState.sortBy != null) {
        filtered = _sortCertificates(
            filtered, currentState.sortBy!, currentState.sortAscending);
      }

      emit(currentState.copyWith(
        filteredCertificates: filtered,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(const CertificateError(message: 'حدث خطأ في البحث'));
    }
  }

  Future<void> _onFilterRequested(
    CertificateFilterRequested event,
    Emitter<CertificateState> emit,
  ) async {
    if (state is! CertificateLoaded) return;
    final currentState = state as CertificateLoaded;
    try {
      List<Certificate> filtered = currentState.certificates;

      if (currentState.searchQuery?.isNotEmpty == true) {
        filtered = filtered
            .where((cert) =>
                (cert.studentId.contains(currentState.searchQuery!)) ||
                (cert.courseId.contains(currentState.searchQuery!)) ||
                (cert.certificateNumber
                    .toLowerCase()
                    .contains(currentState.searchQuery!.toLowerCase())))
            .toList();
      }

      filtered = _applyFilters(filtered, event.status, event.courseId,
          event.startDate, event.endDate);

      if (currentState.sortBy != null) {
        filtered = _sortCertificates(
            filtered, currentState.sortBy!, currentState.sortAscending);
      }

      emit(currentState.copyWith(
        filteredCertificates: filtered,
        statusFilter: event.status,
        courseFilter: event.courseId,
        startDateFilter: event.startDate,
        endDateFilter: event.endDate,
      ));
    } catch (e) {
      emit(const CertificateError(message: 'حدث خطأ في تطبيق الفلاتر'));
    }
  }

  Future<void> _onClearFilters(
    CertificateClearFilters event,
    Emitter<CertificateState> emit,
  ) async {
    if (state is! CertificateLoaded) return;
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

  Future<void> _onSortRequested(
    CertificateSortRequested event,
    Emitter<CertificateState> emit,
  ) async {
    if (state is! CertificateLoaded) return;
    final currentState = state as CertificateLoaded;
    try {
      final sorted = _sortCertificates(
        currentState.filteredCertificates,
        event.sortBy,
        event.ascending,
      );
      emit(currentState.copyWith(
        filteredCertificates: sorted,
        sortBy: event.sortBy,
        sortAscending: event.ascending,
      ));
    } catch (e) {
      emit(const CertificateError(message: 'حدث خطأ في ترتيب الشهادات'));
    }
  }

  Future<void> _onDownloadRequested(
    CertificateDownloadRequested event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateDownloading());
      final certificateData =
          await repository.getCertificateById(event.certificateId);

      if (certificateData != null && certificateData.isNotEmpty) {
        final filePath = certificateData['certificate_url'] ??
            '/downloads/certificate_${certificateData['id']}.pdf';
        emit(CertificateDownloaded(filePath: filePath));
      } else {
        emit(const CertificateError(message: 'لم يتم العثور على الشهادة'));
      }
    } catch (e) {
      emit(CertificateError(message: 'حدث خطأ في تحميل الشهادة: $e'));
    }
  }

  Future<void> _onShareRequested(
    CertificateShareRequested event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateSharing());
      final certificateData =
          await repository.getCertificateById(event.certificateId);

      if (certificateData != null && certificateData.isNotEmpty) {
        final shareUrl =
            'https://wasla.com/certificates/verify/${certificateData['certificate_number']}';
        emit(CertificateShared(shareUrl: shareUrl));
      } else {
        emit(const CertificateError(message: 'لم يتم العثور على الشهادة'));
      }
    } catch (e) {
      emit(CertificateError(message: 'حدث خطأ في مشاركة الشهادة: $e'));
    }
  }

  Future<void> _onVerifyRequested(
    CertificateVerifyRequested event,
    Emitter<CertificateState> emit,
  ) async {
    try {
      emit(CertificateVerifying());
      final certificateData =
          await repository.getCertificateById(event.certificateId);

      if (certificateData != null && certificateData.isNotEmpty) {
        final certificate = Certificate(
          id: certificateData['id'] ?? '',
          courseId: certificateData['course_id'] ?? '',
          studentId: certificateData['student_id'] ?? '',
          providerId: certificateData['provider_id'] ?? '',
          certificateNumber: certificateData['certificate_number'] ?? '',
          issueDate: certificateData['issue_date'] != null
              ? DateTime.parse(certificateData['issue_date'])
              : DateTime.now(),
          expiryDate: certificateData['expiry_date'] != null
              ? DateTime.parse(certificateData['expiry_date'])
              : null,
          certificateUrl: certificateData['certificate_url'],
          status: certificateData['status'] == 'revoked'
              ? CertificateStatus.revoked
              : CertificateStatus.issued,
          createdAt: certificateData['created_at'] != null
              ? DateTime.parse(certificateData['created_at'])
              : DateTime.now(),
        );

        final isValid = certificate.status == CertificateStatus.issued;
        emit(CertificateVerified(certificate: certificate, isValid: isValid));
      } else {
        emit(const CertificateError(message: 'لم يتم العثور على الشهادة'));
      }
    } catch (e) {
      emit(CertificateError(message: 'حدث خطأ في التحقق من الشهادة: $e'));
    }
  }

  List<Certificate> _applyFilters(
    List<Certificate> certificates,
    CertificateStatus? status,
    String? courseId,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return certificates.where((cert) {
      if (status != null && cert.status != status) return false;
      if (courseId != null && cert.courseId != courseId) return false;
      if (startDate != null && cert.issueDate.isBefore(startDate)) return false;
      if (endDate != null && cert.issueDate.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  List<Certificate> _sortCertificates(
    List<Certificate> certificates,
    String sortBy,
    bool ascending,
  ) {
    final sorted = List<Certificate>.from(certificates);
    switch (sortBy) {
      case 'issueDate':
        sorted.sort((a, b) => ascending
            ? a.issueDate.compareTo(b.issueDate)
            : b.issueDate.compareTo(a.issueDate));
        break;
      case 'certificateNumber':
        sorted.sort((a, b) => ascending
            ? a.certificateNumber.compareTo(b.certificateNumber)
            : b.certificateNumber.compareTo(a.certificateNumber));
        break;
    }
    return sorted;
  }
}
