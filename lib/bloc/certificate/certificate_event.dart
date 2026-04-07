import 'package:equatable/equatable.dart';
import '../../data/models/index.dart';

abstract class CertificateEvent extends Equatable {
  const CertificateEvent();

  @override
  List<Object?> get props => [];
}

class CertificateLoadRequested extends CertificateEvent {}

class CertificateIssueRequested extends CertificateEvent {
  final String studentId;
  final String courseId;
  final String courseTitle;

  const CertificateIssueRequested({
    required this.studentId,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  List<Object?> get props => [studentId, courseId, courseTitle];
}

class CertificateRevokeRequested extends CertificateEvent {
  final String certificateId;

  const CertificateRevokeRequested({required this.certificateId});

  @override
  List<Object?> get props => [certificateId];
}

class CertificateRestoreRequested extends CertificateEvent {
  final String certificateId;

  const CertificateRestoreRequested({required this.certificateId});

  @override
  List<Object?> get props => [certificateId];
}

class CertificateSearchRequested extends CertificateEvent {
  final String query;

  const CertificateSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

class CertificateFilterRequested extends CertificateEvent {
  final CertificateStatus? status;
  final String? courseId;
  final DateTime? startDate;
  final DateTime? endDate;

  const CertificateFilterRequested({
    this.status,
    this.courseId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, courseId, startDate, endDate];
}

class CertificateClearFilters extends CertificateEvent {}

class CertificateSortRequested extends CertificateEvent {
  final String sortBy; // 'studentName', 'courseTitle', 'issuedAt'
  final bool ascending;

  const CertificateSortRequested({
    required this.sortBy,
    this.ascending = true,
  });

  @override
  List<Object?> get props => [sortBy, ascending];
}

class CertificateDownloadRequested extends CertificateEvent {
  final String certificateId;

  const CertificateDownloadRequested({required this.certificateId});

  @override
  List<Object?> get props => [certificateId];
}

class CertificateShareRequested extends CertificateEvent {
  final String certificateId;

  const CertificateShareRequested({required this.certificateId});

  @override
  List<Object?> get props => [certificateId];
}

class CertificateVerifyRequested extends CertificateEvent {
  final String certificateId;

  const CertificateVerifyRequested({required this.certificateId});

  @override
  List<Object?> get props => [certificateId];
}
