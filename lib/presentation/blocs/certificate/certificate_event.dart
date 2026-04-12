import 'package:equatable/equatable.dart';
import '../../../data/models/certificate/certificate.dart';

abstract class CertificateEvent extends Equatable {
  const CertificateEvent();

  @override
  List<Object?> get props => [];
}

/// تحميل الطلاب المؤهلين
class LoadEligibleStudents extends CertificateEvent {
  final String courseId;

  const LoadEligibleStudents(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

/// تحميل شهادات الكورس
class LoadCourseCertificates extends CertificateEvent {
  final String courseId;

  const LoadCourseCertificates(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

/// تحميل إعدادات الشهادة
class LoadCertificateSettings extends CertificateEvent {
  final String courseId;

  const LoadCertificateSettings(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

/// حفظ إعدادات الشهادة
class SaveCertificateSettings extends CertificateEvent {
  final String courseId;
  final CertificateSettings settings;

  const SaveCertificateSettings({
    required this.courseId,
    required this.settings,
  });

  @override
  List<Object?> get props => [courseId, settings];
}

/// إصدار شهادة لطالب واحد
class IssueSingleCertificate extends CertificateEvent {
  final String courseId;
  final String studentId;
  final String providerId;
  final String? logoUrl;
  final String? signatureUrl;
  final String? customColor;
  final String? grade;

  const IssueSingleCertificate({
    required this.courseId,
    required this.studentId,
    required this.providerId,
    this.logoUrl,
    this.signatureUrl,
    this.customColor,
    this.grade,
  });

  @override
  List<Object?> get props => [
        courseId,
        studentId,
        providerId,
        logoUrl,
        signatureUrl,
        customColor,
        grade,
      ];
}

/// إصدار شهادات لعدة طلاب
class IssueMultipleCertificates extends CertificateEvent {
  final String courseId;
  final List<String> studentIds;
  final String providerId;
  final String? logoUrl;
  final String? signatureUrl;
  final String? customColor;

  const IssueMultipleCertificates({
    required this.courseId,
    required this.studentIds,
    required this.providerId,
    this.logoUrl,
    this.signatureUrl,
    this.customColor,
  });

  @override
  List<Object?> get props => [
        courseId,
        studentIds,
        providerId,
        logoUrl,
        signatureUrl,
        customColor,
      ];
}

/// إلغاء شهادة
class RevokeCertificate extends CertificateEvent {
  final String certificateId;

  const RevokeCertificate(this.certificateId);

  @override
  List<Object?> get props => [certificateId];
}

/// استعادة شهادة
class RestoreCertificate extends CertificateEvent {
  final String certificateId;

  const RestoreCertificate(this.certificateId);

  @override
  List<Object?> get props => [certificateId];
}

/// حذف شهادة
class DeleteCertificate extends CertificateEvent {
  final String certificateId;

  const DeleteCertificate(this.certificateId);

  @override
  List<Object?> get props => [certificateId];
}

/// البحث في الشهادات
class SearchCertificates extends CertificateEvent {
  final String query;

  const SearchCertificates(this.query);

  @override
  List<Object?> get props => [query];
}

/// تصفية الشهادات
class FilterCertificates extends CertificateEvent {
  final CertificateStatus? status;

  const FilterCertificates({this.status});

  @override
  List<Object?> get props => [status];
}
