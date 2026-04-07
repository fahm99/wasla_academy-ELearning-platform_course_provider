import 'package:equatable/equatable.dart';
import '../../models/index.dart';

abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class StudentLoadRequested extends StudentEvent {}

class StudentAddRequested extends StudentEvent {
  final Enrollment student;

  const StudentAddRequested({required this.student});

  @override
  List<Object?> get props => [student];
}

class StudentUpdateRequested extends StudentEvent {
  final Enrollment student;

  const StudentUpdateRequested({required this.student});

  @override
  List<Object?> get props => [student];
}

class StudentSearchRequested extends StudentEvent {
  final String query;

  const StudentSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

class StudentFilterRequested extends StudentEvent {
  final EnrollmentStatus? status;
  final String? courseId;

  const StudentFilterRequested({
    this.status,
    this.courseId,
  });

  @override
  List<Object?> get props => [status, courseId];
}

class StudentClearFilters extends StudentEvent {}

class StudentEnrollToCourse extends StudentEvent {
  final String studentId;
  final String courseId;

  const StudentEnrollToCourse({
    required this.studentId,
    required this.courseId,
  });

  @override
  List<Object?> get props => [studentId, courseId];
}

class StudentUnenrollFromCourse extends StudentEvent {
  final String studentId;
  final String courseId;

  const StudentUnenrollFromCourse({
    required this.studentId,
    required this.courseId,
  });

  @override
  List<Object?> get props => [studentId, courseId];
}

class StudentActivate extends StudentEvent {
  final String studentId;

  const StudentActivate({required this.studentId});

  @override
  List<Object?> get props => [studentId];
}

class StudentDeactivate extends StudentEvent {
  final String studentId;

  const StudentDeactivate({required this.studentId});

  @override
  List<Object?> get props => [studentId];
}

class StudentSuspend extends StudentEvent {
  final String studentId;

  const StudentSuspend({required this.studentId});

  @override
  List<Object?> get props => [studentId];
}

class StudentSortRequested extends StudentEvent {
  final String sortBy; // 'name', 'email', 'enrollmentDate', 'coursesCount'
  final bool ascending;

  const StudentSortRequested({
    required this.sortBy,
    this.ascending = true,
  });

  @override
  List<Object?> get props => [sortBy, ascending];
}
