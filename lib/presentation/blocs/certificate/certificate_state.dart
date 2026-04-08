import 'package:course_provider/data/models/certificate.dart';
import 'package:equatable/equatable.dart';

abstract class CertificateState extends Equatable {
  const CertificateState();

  @override
  List<Object?> get props => [];
}

class CertificateInitial extends CertificateState {}

class CertificateLoading extends CertificateState {}

class CertificateLoaded extends CertificateState {
  final List<Certificate> certificates;
  final List<Certificate> filteredCertificates;
  final String? searchQuery;
  final CertificateStatus? statusFilter;
  final String? courseFilter;
  final DateTime? startDateFilter;
  final DateTime? endDateFilter;
  final String? sortBy;
  final bool sortAscending;

  const CertificateLoaded({
    required this.certificates,
    required this.filteredCertificates,
    this.searchQuery,
    this.statusFilter,
    this.courseFilter,
    this.startDateFilter,
    this.endDateFilter,
    this.sortBy,
    this.sortAscending = true,
  });

  @override
  List<Object?> get props => [
        certificates,
        filteredCertificates,
        searchQuery,
        statusFilter,
        courseFilter,
        startDateFilter,
        endDateFilter,
        sortBy,
        sortAscending,
      ];

  CertificateLoaded copyWith({
    List<Certificate>? certificates,
    List<Certificate>? filteredCertificates,
    String? searchQuery,
    CertificateStatus? statusFilter,
    String? courseFilter,
    DateTime? startDateFilter,
    DateTime? endDateFilter,
    String? sortBy,
    bool? sortAscending,
  }) {
    return CertificateLoaded(
      certificates: certificates ?? this.certificates,
      filteredCertificates: filteredCertificates ?? this.filteredCertificates,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      courseFilter: courseFilter ?? this.courseFilter,
      startDateFilter: startDateFilter ?? this.startDateFilter,
      endDateFilter: endDateFilter ?? this.endDateFilter,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class CertificateError extends CertificateState {
  final String message;

  const CertificateError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CertificateOperationSuccess extends CertificateState {
  final String message;
  final List<Certificate> certificates;

  const CertificateOperationSuccess({
    required this.message,
    required this.certificates,
  });

  @override
  List<Object?> get props => [message, certificates];
}

class CertificateIssuing extends CertificateState {}

class CertificateRevoking extends CertificateState {}

class CertificateDownloading extends CertificateState {}

class CertificateSharing extends CertificateState {}

class CertificateVerifying extends CertificateState {}

class CertificateVerified extends CertificateState {
  final Certificate certificate;
  final bool isValid;

  const CertificateVerified({
    required this.certificate,
    required this.isValid,
  });

  @override
  List<Object?> get props => [certificate, isValid];
}

class CertificateDownloaded extends CertificateState {
  final String filePath;

  const CertificateDownloaded({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class CertificateShared extends CertificateState {
  final String shareUrl;

  const CertificateShared({required this.shareUrl});

  @override
  List<Object?> get props => [shareUrl];
}
