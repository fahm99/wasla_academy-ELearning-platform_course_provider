import 'package:equatable/equatable.dart';
import '../../models/index.dart';

abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<Enrollment> students;
  final List<Enrollment> filteredStudents;
  final String? searchQuery;
  final EnrollmentStatus? statusFilter;
  final String? courseFilter;
  final String? sortBy;
  final bool sortAscending;

  const StudentLoaded({
    required this.students,
    required this.filteredStudents,
    this.searchQuery,
    this.statusFilter,
    this.courseFilter,
    this.sortBy,
    this.sortAscending = true,
  });

  @override
  List<Object?> get props => [
        students,
        filteredStudents,
        searchQuery,
        statusFilter,
        courseFilter,
        sortBy,
        sortAscending,
      ];

  StudentLoaded copyWith({
    List<Enrollment>? students,
    List<Enrollment>? filteredStudents,
    String? searchQuery,
    EnrollmentStatus? statusFilter,
    String? courseFilter,
    String? sortBy,
    bool? sortAscending,
  }) {
    return StudentLoaded(
      students: students ?? this.students,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      courseFilter: courseFilter ?? this.courseFilter,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class StudentError extends StudentState {
  final String message;

  const StudentError({required this.message});

  @override
  List<Object?> get props => [message];
}

class StudentOperationSuccess extends StudentState {
  final String message;
  final List<Enrollment> students;

  const StudentOperationSuccess({
    required this.message,
    required this.students,
  });

  @override
  List<Object?> get props => [message, students];
}

class StudentAdding extends StudentState {}

class StudentUpdating extends StudentState {}

class StudentEnrolling extends StudentState {}

class StudentStatusChanging extends StudentState {}
