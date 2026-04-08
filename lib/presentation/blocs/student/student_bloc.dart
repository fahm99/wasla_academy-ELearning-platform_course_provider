import 'package:course_provider/data/models/student.dart';
import 'package:course_provider/data/repositories/main_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'student_event.dart';
import 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final MainRepository repository;

  StudentBloc({required this.repository}) : super(StudentInitial()) {
    on<StudentLoadRequested>(_onLoadRequested);
    on<StudentAddRequested>(_onAddRequested);
    on<StudentUpdateRequested>(_onUpdateRequested);
    on<StudentSearchRequested>(_onSearchRequested);
    on<StudentFilterRequested>(_onFilterRequested);
    on<StudentClearFilters>(_onClearFilters);
    on<StudentEnrollToCourse>(_onEnrollToCourse);
    on<StudentUnenrollFromCourse>(_onUnenrollFromCourse);
    on<StudentSortRequested>(_onSortRequested);
  }

  Future<void> _onLoadRequested(
    StudentLoadRequested event,
    Emitter<StudentState> emit,
  ) async {
    try {
      emit(StudentLoading());
      final students = await repository.getStudents();
      emit(StudentLoaded(students: students, filteredStudents: students));
    } catch (e) {
      emit(const StudentError(message: 'حدث خطأ في تحميل الطلاب'));
    }
  }

  Future<void> _onAddRequested(
    StudentAddRequested event,
    Emitter<StudentState> emit,
  ) async {
    try {
      emit(StudentAdding());
      await repository.addStudent(event.student);
      final students = await repository.getStudents();
      emit(StudentOperationSuccess(
          message: 'تم إضافة الطالب بنجاح', students: students));
      emit(StudentLoaded(students: students, filteredStudents: students));
    } catch (e) {
      emit(const StudentError(message: 'حدث خطأ في إضافة الطالب'));
    }
  }

  Future<void> _onUpdateRequested(
    StudentUpdateRequested event,
    Emitter<StudentState> emit,
  ) async {
    try {
      emit(StudentUpdating());
      await repository.updateStudent(event.student);
      final students = await repository.getStudents();
      emit(StudentOperationSuccess(
          message: 'تم تحديث بيانات الطالب بنجاح', students: students));
      emit(StudentLoaded(students: students, filteredStudents: students));
    } catch (e) {
      emit(const StudentError(message: 'حدث خطأ في تحديث بيانات الطالب'));
    }
  }

  Future<void> _onSearchRequested(
    StudentSearchRequested event,
    Emitter<StudentState> emit,
  ) async {
    if (state is! StudentLoaded) return;
    final currentState = state as StudentLoaded;
    try {
      List<Enrollment> filtered = event.query.isEmpty
          ? currentState.students
          : currentState.students
              .where((e) =>
                  e.studentId.contains(event.query) ||
                  e.courseId.contains(event.query))
              .toList();

      filtered = _applyFilters(
          filtered, currentState.statusFilter, currentState.courseFilter);

      if (currentState.sortBy != null) {
        filtered = _sortStudents(
            filtered, currentState.sortBy!, currentState.sortAscending);
      }

      emit(currentState.copyWith(
          filteredStudents: filtered, searchQuery: event.query));
    } catch (e) {
      emit(const StudentError(message: 'حدث خطأ في البحث'));
    }
  }

  Future<void> _onFilterRequested(
    StudentFilterRequested event,
    Emitter<StudentState> emit,
  ) async {
    if (state is! StudentLoaded) return;
    final currentState = state as StudentLoaded;
    try {
      List<Enrollment> filtered = currentState.students;

      if (currentState.searchQuery?.isNotEmpty == true) {
        filtered = filtered
            .where((e) =>
                e.studentId.contains(currentState.searchQuery!) ||
                e.courseId.contains(currentState.searchQuery!))
            .toList();
      }

      filtered = _applyFilters(filtered, event.status, event.courseId);

      if (currentState.sortBy != null) {
        filtered = _sortStudents(
            filtered, currentState.sortBy!, currentState.sortAscending);
      }

      emit(currentState.copyWith(
        filteredStudents: filtered,
        statusFilter: event.status,
        courseFilter: event.courseId,
      ));
    } catch (e) {
      emit(const StudentError(message: 'حدث خطأ في تطبيق الفلاتر'));
    }
  }

  Future<void> _onClearFilters(
    StudentClearFilters event,
    Emitter<StudentState> emit,
  ) async {
    if (state is! StudentLoaded) return;
    final currentState = state as StudentLoaded;
    emit(currentState.copyWith(
      filteredStudents: currentState.students,
      searchQuery: null,
      statusFilter: null,
      courseFilter: null,
      sortBy: null,
      sortAscending: true,
    ));
  }

  Future<void> _onEnrollToCourse(
    StudentEnrollToCourse event,
    Emitter<StudentState> emit,
  ) async {
    try {
      emit(StudentEnrolling());
      final success = await repository.enrollStudent(
        studentId: event.studentId,
        courseId: event.courseId,
      );
      final students = await repository.getStudents();
      if (success) {
        emit(StudentOperationSuccess(
            message: 'تم تسجيل الطالب في الدورة بنجاح', students: students));
      } else {
        emit(const StudentError(message: 'الطالب مسجل بالفعل في هذه الدورة'));
      }
      emit(StudentLoaded(students: students, filteredStudents: students));
    } catch (e) {
      emit(const StudentError(message: 'حدث خطأ في تسجيل الطالب في الدورة'));
    }
  }

  Future<void> _onUnenrollFromCourse(
    StudentUnenrollFromCourse event,
    Emitter<StudentState> emit,
  ) async {
    try {
      emit(StudentEnrolling());
      final students = await repository.getStudents();
      emit(StudentOperationSuccess(
          message: 'تم إلغاء تسجيل الطالب من الدورة بنجاح',
          students: students));
      emit(StudentLoaded(students: students, filteredStudents: students));
    } catch (e) {
      emit(const StudentError(
          message: 'حدث خطأ في إلغاء تسجيل الطالب من الدورة'));
    }
  }

  Future<void> _onSortRequested(
    StudentSortRequested event,
    Emitter<StudentState> emit,
  ) async {
    if (state is! StudentLoaded) return;
    final currentState = state as StudentLoaded;
    try {
      final sorted = _sortStudents(
          currentState.filteredStudents, event.sortBy, event.ascending);
      emit(currentState.copyWith(
        filteredStudents: sorted,
        sortBy: event.sortBy,
        sortAscending: event.ascending,
      ));
    } catch (e) {
      emit(const StudentError(message: 'حدث خطأ في ترتيب الطلاب'));
    }
  }

  List<Enrollment> _applyFilters(
    List<Enrollment> students,
    EnrollmentStatus? status,
    String? courseId,
  ) {
    return students.where((e) {
      if (status != null && e.status != status) return false;
      if (courseId != null && e.courseId != courseId) return false;
      return true;
    }).toList();
  }

  List<Enrollment> _sortStudents(
    List<Enrollment> students,
    String sortBy,
    bool ascending,
  ) {
    final sorted = List<Enrollment>.from(students);
    switch (sortBy) {
      case 'enrollmentDate':
        sorted.sort((a, b) => ascending
            ? a.enrollmentDate.compareTo(b.enrollmentDate)
            : b.enrollmentDate.compareTo(a.enrollmentDate));
        break;
      case 'completion':
        sorted.sort((a, b) => ascending
            ? a.completionPercentage.compareTo(b.completionPercentage)
            : b.completionPercentage.compareTo(a.completionPercentage));
        break;
    }
    return sorted;
  }
}
