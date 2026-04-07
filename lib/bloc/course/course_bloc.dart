import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/main_repository.dart';
import '../../models/index.dart';
import 'course_event.dart';
import 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final MainRepository repository;

  CourseBloc({required this.repository}) : super(CourseInitial()) {
    on<CourseLoadRequested>(_onLoadRequested);
    on<CourseAddRequested>(_onAddRequested);
    on<CourseUpdateRequested>(_onUpdateRequested);
    on<CourseDeleteRequested>(_onDeleteRequested);
    on<CourseSearchRequested>(_onSearchRequested);
    on<CourseFilterRequested>(_onFilterRequested);
    on<CourseClearFilters>(_onClearFilters);
    on<CoursePublishRequested>(_onPublishRequested);
    on<CourseUnpublishRequested>(_onUnpublishRequested);
    on<CourseDuplicateRequested>(_onDuplicateRequested);
    on<CourseArchiveRequested>(_onArchiveRequested);
    on<CourseRestoreRequested>(_onRestoreRequested);
    on<CourseSortRequested>(_onSortRequested);
  }

  Future<void> _onLoadRequested(
    CourseLoadRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(CourseLoading());

      final courses = await repository.getCourses();

      emit(CourseLoaded(
        courses: courses,
        filteredCourses: courses,
      ));
    } catch (e) {
      emit(const CourseError(message: 'حدث خطأ في تحميل الدورات'));
    }
  }

  Future<void> _onAddRequested(
    CourseAddRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(CourseAdding());

      await repository.addCourse(event.course);
      final courses = await repository.getCourses();

      emit(CourseOperationSuccess(
        message: 'تم إضافة الدورة بنجاح',
        courses: courses,
      ));

      emit(CourseLoaded(
        courses: courses,
        filteredCourses: courses,
      ));
    } catch (e) {
      emit(const CourseError(message: 'حدث خطأ في إضافة الدورة'));
    }
  }

  Future<void> _onUpdateRequested(
    CourseUpdateRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(CourseUpdating());

      await repository.updateCourse(event.course);
      final courses = await repository.getCourses();

      emit(CourseOperationSuccess(
        message: 'تم تحديث الدورة بنجاح',
        courses: courses,
      ));

      emit(CourseLoaded(
        courses: courses,
        filteredCourses: courses,
      ));
    } catch (e) {
      emit(const CourseError(message: 'حدث خطأ في تحديث الدورة'));
    }
  }

  Future<void> _onDeleteRequested(
    CourseDeleteRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(CourseDeleting());

      await repository.deleteCourse(event.courseId);
      final courses = await repository.getCourses();

      emit(CourseOperationSuccess(
        message: 'تم حذف الدورة بنجاح',
        courses: courses,
      ));

      emit(CourseLoaded(
        courses: courses,
        filteredCourses: courses,
      ));
    } catch (e) {
      emit(const CourseError(message: 'حدث خطأ في حذف الدورة'));
    }
  }

  Future<void> _onSearchRequested(
    CourseSearchRequested event,
    Emitter<CourseState> emit,
  ) async {
    if (state is CourseLoaded) {
      final currentState = state as CourseLoaded;

      try {
        List<Course> filteredCourses;

        if (event.query.isEmpty) {
          filteredCourses = currentState.courses;
        } else {
          filteredCourses = currentState.courses.where((course) {
            return course.title
                    .toLowerCase()
                    .contains(event.query.toLowerCase()) ||
                course.description
                    .toLowerCase()
                    .contains(event.query.toLowerCase()) ||
                (course.category
                        ?.toLowerCase()
                        .contains(event.query.toLowerCase()) ??
                    false);
          }).toList();
        }

        // تطبيق الفلاتر الحالية
        filteredCourses = _applyFilters(
          filteredCourses,
          currentState.statusFilter,
          currentState.levelFilter,
          currentState.categoryFilter,
        );

        // تطبيق الترتيب الحالي
        if (currentState.sortBy != null) {
          filteredCourses = _sortCourses(
            filteredCourses,
            currentState.sortBy!,
            currentState.sortAscending,
          );
        }

        emit(currentState.copyWith(
          filteredCourses: filteredCourses,
          searchQuery: event.query,
        ));
      } catch (e) {
        emit(const CourseError(message: 'حدث خطأ في البحث'));
      }
    }
  }

  Future<void> _onFilterRequested(
    CourseFilterRequested event,
    Emitter<CourseState> emit,
  ) async {
    if (state is CourseLoaded) {
      final currentState = state as CourseLoaded;

      try {
        List<Course> filteredCourses = currentState.courses;

        // تطبيق البحث أولاً
        if (currentState.searchQuery != null &&
            currentState.searchQuery!.isNotEmpty) {
          filteredCourses = filteredCourses.where((course) {
            return course.title
                    .toLowerCase()
                    .contains(currentState.searchQuery!.toLowerCase()) ||
                course.description
                    .toLowerCase()
                    .contains(currentState.searchQuery!.toLowerCase()) ||
                (course.category
                        ?.toLowerCase()
                        .contains(currentState.searchQuery!.toLowerCase()) ??
                    false);
          }).toList();
        }

        // تطبيق الفلاتر
        filteredCourses = _applyFilters(
          filteredCourses,
          event.status,
          event.level,
          event.category,
        );

        // تطبيق الترتيب الحالي
        if (currentState.sortBy != null) {
          filteredCourses = _sortCourses(
            filteredCourses,
            currentState.sortBy!,
            currentState.sortAscending,
          );
        }

        emit(currentState.copyWith(
          filteredCourses: filteredCourses,
          statusFilter: event.status,
          levelFilter: event.level,
          categoryFilter: event.category,
        ));
      } catch (e) {
        emit(const CourseError(message: 'حدث خطأ في تطبيق الفلاتر'));
      }
    }
  }

  Future<void> _onClearFilters(
    CourseClearFilters event,
    Emitter<CourseState> emit,
  ) async {
    if (state is CourseLoaded) {
      final currentState = state as CourseLoaded;

      emit(currentState.copyWith(
        filteredCourses: currentState.courses,
        searchQuery: null,
        statusFilter: null,
        levelFilter: null,
        categoryFilter: null,
        sortBy: null,
        sortAscending: true,
      ));
    }
  }

  Future<void> _onPublishRequested(
    CoursePublishRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(CoursePublishing());

      await repository.publishCourse(event.courseId);
      final courses = await repository.getCourses();

      emit(CourseOperationSuccess(
        message: 'تم نشر الدورة بنجاح',
        courses: courses,
      ));

      emit(CourseLoaded(
        courses: courses,
        filteredCourses: courses,
      ));
    } catch (e) {
      emit(const CourseError(message: 'حدث خطأ في نشر الدورة'));
    }
  }

  Future<void> _onUnpublishRequested(
    CourseUnpublishRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(CoursePublishing());

      await repository.unpublishCourse(event.courseId);
      final courses = await repository.getCourses();

      emit(CourseOperationSuccess(
        message: 'تم إلغاء نشر الدورة بنجاح',
        courses: courses,
      ));

      emit(CourseLoaded(
        courses: courses,
        filteredCourses: courses,
      ));
    } catch (e) {
      emit(const CourseError(message: 'حدث خطأ في إلغاء نشر الدورة'));
    }
  }

  Future<void> _onDuplicateRequested(
    CourseDuplicateRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(CourseAdding());

      final course = await repository.getCourseById(event.courseId);
      if (course != null) {
        final duplicatedCourse = course.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '${course.title} - نسخة',
          status: CourseStatus.draft,
          studentsCount: 0,
          rating: 0,
          reviewsCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.addCourse(duplicatedCourse);
        final courses = await repository.getCourses();

        emit(CourseOperationSuccess(
          message: 'تم نسخ الدورة بنجاح',
          courses: courses,
        ));

        emit(CourseLoaded(
          courses: courses,
          filteredCourses: courses,
        ));
      } else {
        emit(const CourseError(message: 'لم يتم العثور على الدورة'));
      }
    } catch (e) {
      emit(const CourseError(message: 'حدث خطأ في نسخ الدورة'));
    }
  }

  Future<void> _onArchiveRequested(
    CourseArchiveRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(CourseArchiving());

      final course = await repository.getCourseById(event.courseId);
      if (course != null) {
        final updatedCourse = course.copyWith(status: CourseStatus.archived);

        await repository.updateCourse(updatedCourse);
        final courses = await repository.getCourses();

        emit(CourseOperationSuccess(
          message: 'تم أرشفة الدورة بنجاح',
          courses: courses,
        ));

        emit(CourseLoaded(
          courses: courses,
          filteredCourses: courses,
        ));
      } else {
        emit(const CourseError(message: 'لم يتم العثور على الدورة'));
      }
    } catch (e) {
      emit(const CourseError(message: 'حدث خطأ في أرشفة الدورة'));
    }
  }

  Future<void> _onRestoreRequested(
    CourseRestoreRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(CourseUpdating());

      final course = await repository.getCourseById(event.courseId);
      if (course != null) {
        final updatedCourse = course.copyWith(status: CourseStatus.draft);

        await repository.updateCourse(updatedCourse);
        final courses = await repository.getCourses();

        emit(CourseOperationSuccess(
          message: 'تم استعادة الدورة بنجاح',
          courses: courses,
        ));

        emit(CourseLoaded(
          courses: courses,
          filteredCourses: courses,
        ));
      } else {
        emit(const CourseError(message: 'لم يتم العثور على الدورة'));
      }
    } catch (e) {
      emit(const CourseError(message: 'حدث خطأ في استعادة الدورة'));
    }
  }

  Future<void> _onSortRequested(
    CourseSortRequested event,
    Emitter<CourseState> emit,
  ) async {
    if (state is CourseLoaded) {
      final currentState = state as CourseLoaded;

      try {
        final sortedCourses = _sortCourses(
          currentState.filteredCourses,
          event.sortBy,
          event.ascending,
        );

        emit(currentState.copyWith(
          filteredCourses: sortedCourses,
          sortBy: event.sortBy,
          sortAscending: event.ascending,
        ));
      } catch (e) {
        emit(const CourseError(message: 'حدث خطأ في ترتيب الدورات'));
      }
    }
  }

  List<Course> _applyFilters(
    List<Course> courses,
    CourseStatus? status,
    CourseLevel? level,
    String? category,
  ) {
    return courses.where((course) {
      if (status != null && course.status != status) return false;
      if (level != null && course.level != level) return false;
      if (category != null && course.category != category) return false;
      return true;
    }).toList();
  }

  List<Course> _sortCourses(
    List<Course> courses,
    String sortBy,
    bool ascending,
  ) {
    final sortedCourses = List<Course>.from(courses);

    switch (sortBy) {
      case 'title':
        sortedCourses.sort((a, b) => ascending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
        break;
      case 'date':
        sortedCourses.sort((a, b) => ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case 'students':
        sortedCourses.sort((a, b) => ascending
            ? a.studentsCount.compareTo(b.studentsCount)
            : b.studentsCount.compareTo(a.studentsCount));
        break;
      case 'rating':
        sortedCourses.sort((a, b) => ascending
            ? a.rating.compareTo(b.rating)
            : b.rating.compareTo(a.rating));
        break;
      case 'price':
        sortedCourses.sort((a, b) => ascending
            ? a.price.compareTo(b.price)
            : b.price.compareTo(a.price));
        break;
    }

    return sortedCourses;
  }
}
