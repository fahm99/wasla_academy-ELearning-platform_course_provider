import 'package:course_provider/data/models/course.dart';
import 'package:equatable/equatable.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class CourseLoadRequested extends CourseEvent {}

class CourseAddRequested extends CourseEvent {
  final Course course;

  const CourseAddRequested({required this.course});

  @override
  List<Object?> get props => [course];
}

class CourseUpdateRequested extends CourseEvent {
  final Course course;

  const CourseUpdateRequested({required this.course});

  @override
  List<Object?> get props => [course];
}

class CourseDeleteRequested extends CourseEvent {
  final String courseId;

  const CourseDeleteRequested({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

class CourseSearchRequested extends CourseEvent {
  final String query;

  const CourseSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

class CourseFilterRequested extends CourseEvent {
  final CourseStatus? status;
  final CourseLevel? level;
  final String? category;
  final bool? isFree;

  const CourseFilterRequested({
    this.status,
    this.level,
    this.category,
    this.isFree,
  });

  @override
  List<Object?> get props => [status, level, category, isFree];
}

class CourseClearFilters extends CourseEvent {}

class CoursePublishRequested extends CourseEvent {
  final String courseId;

  const CoursePublishRequested({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

class CourseUnpublishRequested extends CourseEvent {
  final String courseId;

  const CourseUnpublishRequested({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

class CourseDuplicateRequested extends CourseEvent {
  final String courseId;

  const CourseDuplicateRequested({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

class CourseArchiveRequested extends CourseEvent {
  final String courseId;

  const CourseArchiveRequested({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

class CourseRestoreRequested extends CourseEvent {
  final String courseId;

  const CourseRestoreRequested({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

class CourseSortRequested extends CourseEvent {
  final String sortBy; // 'title', 'date', 'students', 'rating'
  final bool ascending;

  const CourseSortRequested({
    required this.sortBy,
    this.ascending = true,
  });

  @override
  List<Object?> get props => [sortBy, ascending];
}
