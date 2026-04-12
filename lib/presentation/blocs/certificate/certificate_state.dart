import 'package:equatable/equatable.dart';
import '../../../data/models/certificate/certificate.dart';

abstract class CertificateState extends Equatable {
  const CertificateState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class CertificateInitial extends CertificateState {}

/// جاري التحميل
class CertificateLoading extends CertificateState {}

/// تم تحميل الطلاب المؤهلين
class EligibleStudentsLoaded extends CertificateState {
  final List<EligibleStudent> students;

  const EligibleStudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

/// تم تحميل شهادات الكورس
class CourseCertificatesLoaded extends CertificateState {
  final List<Certificate> certificates;
  final List<Certificate> filteredCertificates;
  final String? searchQuery;
  final CertificateStatus? statusFilter;

  const CourseCertificatesLoaded({
    required this.certificates,
    required this.filteredCertificates,
    this.searchQuery,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [
        certificates,
        filteredCertificates,
        searchQuery,
        statusFilter,
      ];

  CourseCertificatesLoaded copyWith({
    List<Certificate>? certificates,
    List<Certificate>? filteredCertificates,
    String? searchQuery,
    CertificateStatus? statusFilter,
    bool clearSearch = false,
    bool clearFilter = false,
  }) {
    return CourseCertificatesLoaded(
      certificates: certificates ?? this.certificates,
      filteredCertificates: filteredCertificates ?? this.filteredCertificates,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      statusFilter: clearFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

/// تم تحميل إعدادات الشهادة
class CertificateSettingsLoaded extends CertificateState {
  final CertificateSettings settings;

  const CertificateSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// جاري إصدار الشهادات
class CertificatesIssuing extends CertificateState {
  final int total;
  final int current;

  const CertificatesIssuing({
    required this.total,
    required this.current,
  });

  @override
  List<Object?> get props => [total, current];
}

/// تم إصدار الشهادات بنجاح
class CertificatesIssued extends CertificateState {
  final int successCount;
  final int failedCount;
  final Map<String, String> errors;
  final String message;

  const CertificatesIssued({
    required this.successCount,
    required this.failedCount,
    required this.errors,
    required this.message,
  });

  @override
  List<Object?> get props => [successCount, failedCount, errors, message];
}

/// تم حفظ الإعدادات بنجاح
class CertificateSettingsSaved extends CertificateState {
  final String message;

  const CertificateSettingsSaved(this.message);

  @override
  List<Object?> get props => [message];
}

/// تمت العملية بنجاح
class CertificateOperationSuccess extends CertificateState {
  final String message;

  const CertificateOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// حدث خطأ
class CertificateError extends CertificateState {
  final String message;

  const CertificateError(this.message);

  @override
  List<Object?> get props => [message];
}
