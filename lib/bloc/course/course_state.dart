import 'package:equatable/equatable.dart';
import '../../models/index.dart';

abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<Course> courses;
  final List<Course> filteredCourses;
  final String? searchQuery;
  final CourseStatus? statusFilter;
  final CourseLevel? levelFilter;
  final String? categoryFilter;
  final bool? isFreeFilter;
  final String? sortBy;
  final bool sortAscending;

  const CourseLoaded({
    required this.courses,
    required this.filteredCourses,
    this.searchQuery,
    this.statusFilter,
    this.levelFilter,
    this.categoryFilter,
    this.isFreeFilter,
    this.sortBy,
    this.sortAscending = true,
  });

  @override
  List<Object?> get props => [
        courses,
        filteredCourses,
        searchQuery,
        statusFilter,
        levelFilter,
        categoryFilter,
        isFreeFilter,
        sortBy,
        sortAscending,
      ];

  CourseLoaded copyWith({
    List<Course>? courses,
    List<Course>? filteredCourses,
    String? searchQuery,
    CourseStatus? statusFilter,
    CourseLevel? levelFilter,
    String? categoryFilter,
    bool? isFreeFilter,
    String? sortBy,
    bool? sortAscending,
  }) {
    return CourseLoaded(
      courses: courses ?? this.courses,
      filteredCourses: filteredCourses ?? this.filteredCourses,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      levelFilter: levelFilter ?? this.levelFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      isFreeFilter: isFreeFilter ?? this.isFreeFilter,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class CourseError extends CourseState {
  final String message;

  const CourseError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CourseOperationSuccess extends CourseState {
  final String message;
  final List<Course> courses;

  const CourseOperationSuccess({
    required this.message,
    required this.courses,
  });

  @override
  List<Object?> get props => [message, courses];
}

class CourseAdding extends CourseState {}

class CourseUpdating extends CourseState {}

class CourseDeleting extends CourseState {}

class CoursePublishing extends CourseState {}

class CourseArchiving extends CourseState {}
