import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/main_repository.dart';
import '../../models/index.dart';
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
    on<StudentActivate>(_onActivate);
    on<StudentDeactivate>(_onDeactivate);
    on<StudentSuspend>(_onSuspend);
    on<StudentSortRequested>(_onSortRequested);
  }

  Future<void> _onLoadRequested(
    StudentLoadRequested event,
    Emitter<StudentState> emit,
  ) async {
    try {
      emit(StudentLoading());

      final students = await repository.getStudents();

      emit(StudentLoaded(
        students: students,
        filteredStudents: students,
      ));
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
        message: 'تم إضافة الطالب بنجاح',
        students: students,
      ));

      emit(StudentLoaded(
        students: students,
        filteredStudents: students,
      ));
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
        message: 'تم تحديث بيانات الطالب بنجاح',
        students: students,
      ));

      emit(StudentLoaded(
        students: students,
        filteredStudents: students,
      ));
    } catch (e) {
      emit(const StudentError(message: 'حدث خطأ في تحديث بيانات الطالب'));
    }
  }

  Future<void> _onSearchRequested(
    StudentSearchRequested event,
    Emitter<StudentState> emit,
  ) async {
    if (state is StudentLoaded) {
      final currentState = state as StudentLoaded;

      try {
        List<Student> filteredStudents;

        if (event.query.isEmpty) {
          filteredStudents = currentState.students;
        } else {
          filteredStudents = currentState.students.where((student) {
            return student.name
                    .toLowerCase()
                    .contains(event.query.toLowerCase()) ||
                student.email
                    .toLowerCase()
                    .contains(event.query.toLowerCase()) ||
                (student.phone
                        ?.toLowerCase()
                        .contains(event.query.toLowerCase()) ??
                    false);
          }).toList();
        }

        // تطبيق الفلاتر الحالية
        filteredStudents = _applyFilters(
          filteredStudents,
          currentState.statusFilter,
          currentState.courseFilter,
        );

        // تطبيق الترتيب الحالي
        if (currentState.sortBy != null) {
          filteredStudents = _sortStudents(
            filteredStudents,
            currentState.sortBy!,
            currentState.sortAscending,
          );
        }

        emit(currentState.copyWith(
          filteredStudents: filteredStudents,
          searchQuery: event.query,
        ));
      } catch (e) {
        emit(const StudentError(message: 'حدث خطأ في البحث'));
      }
    }
  }

  Future<void> _onFilterRequested(
    StudentFilterRequested event,
    Emitter<StudentState> emit,
  ) async {
    if (state is StudentLoaded) {
      final currentState = state as StudentLoaded;

      try {
        List<Student> filteredStudents = currentState.students;

        // تطبيق البحث أولاً
        if (currentState.searchQuery != null &&
            currentState.searchQuery!.isNotEmpty) {
          filteredStudents = filteredStudents.where((student) {
            return student.name
                    .toLowerCase()
                    .contains(currentState.searchQuery!.toLowerCase()) ||
                student.email
                    .toLowerCase()
                    .contains(currentState.searchQuery!.toLowerCase()) ||
                (student.phone
                        ?.toLowerCase()
                        .contains(currentState.searchQuery!.toLowerCase()) ??
                    false);
          }).toList();
        }

        // تطبيق الفلاتر
        filteredStudents = _applyFilters(
          filteredStudents,
          event.status,
          event.courseId,
        );

        // تطبيق الترتيب الحالي
        if (currentState.sortBy != null) {
          filteredStudents = _sortStudents(
            filteredStudents,
            currentState.sortBy!,
            currentState.sortAscending,
          );
        }

        emit(currentState.copyWith(
          filteredStudents: filteredStudents,
          statusFilter: event.status,
          courseFilter: event.courseId,
        ));
      } catch (e) {
        emit(const StudentError(message: 'حدث خطأ في تطبيق الفلاتر'));
      }
    }
  }

  Future<void> _onClearFilters(
    StudentClearFilters event,
    Emitter<StudentState> emit,
  ) async {
    if (state is StudentLoaded) {
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
  }

  Future<void> _onEnrollToCourse(
    StudentEnrollToCourse event,
    Emitter<StudentState> emit,
  ) async {
    try {
      emit(StudentEnrolling());

      final student = await repository.getStudentById(event.studentId);
      if (student != null) {
        final enrolledCourses = List<String>.from(student.enrolledCourses);
        if (!enrolledCourses.contains(event.courseId)) {
          enrolledCourses.add(event.courseId);

          final updatedStudent =
              student.copyWith(enrolledCourses: enrolledCourses);
          await repository.updateStudent(updatedStudent);

          final students = await repository.getStudents();

          emit(StudentOperationSuccess(
            message: 'تم تسجيل الطالب في الدورة بنجاح',
            students: students,
          ));

          emit(StudentLoaded(
            students: students,
            filteredStudents: students,
          ));
        } else {
          emit(const StudentError(message: 'الطالب مسجل بالفعل في هذه الدورة'));
        }
      } else {
        emit(const StudentError(message: 'لم يتم العثور على الطالب'));
      }
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

      final student = await repository.getStudentById(event.studentId);
      if (student != null) {
        final enrolledCourses = List<String>.from(student.enrolledCourses);
        enrolledCourses.remove(event.courseId);

        final updatedStudent =
            student.copyWith(enrolledCourses: enrolledCourses);
        await repository.updateStudent(updatedStudent);

        final students = await repository.getStudents();

        emit(StudentOperationSuccess(
          message: 'تم إلغاء تسجيل الطالب من الدورة بنجاح',
          students: students,
        ));

        emit(StudentLoaded(
          students: students,
          filteredStudents: students,
        ));
      } else {
        emit(const StudentError(message: 'لم يتم العثور على الطالب'));
      }
    } catch (e) {
      emit(const StudentError(
          message: 'حدث خطأ في إلغاء تسجيل الطالب من الدورة'));
    }
  }

  Future<void> _onActivate(
    StudentActivate event,
    Emitter<StudentState> emit,
  ) async {
    await _changeStudentStatus(
        event.studentId, StudentStatus.active, 'تم تفعيل الطالب بنجاح', emit);
  }

  Future<void> _onDeactivate(
    StudentDeactivate event,
    Emitter<StudentState> emit,
  ) async {
    await _changeStudentStatus(event.studentId, StudentStatus.inactive,
        'تم إلغاء تفعيل الطالب بنجاح', emit);
  }

  Future<void> _onSuspend(
    StudentSuspend event,
    Emitter<StudentState> emit,
  ) async {
    await _changeStudentStatus(event.studentId, StudentStatus.suspended,
        'تم إيقاف الطالب بنجاح', emit);
  }

  Future<void> _changeStudentStatus(
    String studentId,
    StudentStatus status,
    String successMessage,
    Emitter<StudentState> emit,
  ) async {
    try {
      emit(StudentStatusChanging());

      final student = await repository.getStudentById(studentId);
      if (student != null) {
        final updatedStudent = student.copyWith(status: status);
        await repository.updateStudent(updatedStudent);

        final students = await repository.getStudents();

        emit(StudentOperationSuccess(
          message: successMessage,
          students: students,
        ));

        emit(StudentLoaded(
          students: students,
          filteredStudents: students,
        ));
      } else {
        emit(const StudentError(message: 'لم يتم العثور على الطالب'));
      }
    } catch (e) {
      emit(const StudentError(message: 'حدث خطأ في تغيير حالة الطالب'));
    }
  }

  Future<void> _onSortRequested(
    StudentSortRequested event,
    Emitter<StudentState> emit,
  ) async {
    if (state is StudentLoaded) {
      final currentState = state as StudentLoaded;

      try {
        final sortedStudents = _sortStudents(
          currentState.filteredStudents,
          event.sortBy,
          event.ascending,
        );

        emit(currentState.copyWith(
          filteredStudents: sortedStudents,
          sortBy: event.sortBy,
          sortAscending: event.ascending,
        ));
      } catch (e) {
        emit(const StudentError(message: 'حدث خطأ في ترتيب الطلاب'));
      }
    }
  }

  List<Student> _applyFilters(
    List<Student> students,
    StudentStatus? status,
    String? courseId,
  ) {
    return students.where((student) {
      if (status != null && student.status != status) return false;
      if (courseId != null && !student.enrolledCourses.contains(courseId)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Student> _sortStudents(
    List<Student> students,
    String sortBy,
    bool ascending,
  ) {
    final sortedStudents = List<Student>.from(students);

    switch (sortBy) {
      case 'name':
        sortedStudents.sort((a, b) =>
            ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
        break;
      case 'email':
        sortedStudents.sort((a, b) => ascending
            ? a.email.compareTo(b.email)
            : b.email.compareTo(a.email));
        break;
      case 'enrollmentDate':
        sortedStudents.sort((a, b) => ascending
            ? a.enrollmentDate.compareTo(b.enrollmentDate)
            : b.enrollmentDate.compareTo(a.enrollmentDate));
        break;
      case 'coursesCount':
        sortedStudents.sort((a, b) => ascending
            ? a.enrolledCourses.length.compareTo(b.enrolledCourses.length)
            : b.enrolledCourses.length.compareTo(a.enrolledCourses.length));
        break;
    }

    return sortedStudents;
  }
}
