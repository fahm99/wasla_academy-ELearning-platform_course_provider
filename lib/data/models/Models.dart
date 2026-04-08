import 'package:equatable/equatable.dart';

// نموذج المستخدم
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final UserType type;
  final DateTime createdAt;
  final bool isActive;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.type,
    required this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props =>
      [id, name, email, phone, avatar, type, createdAt, isActive];

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    UserType? type,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      type: UserType.values.firstWhere((e) => e.name == json['type']),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}

enum UserType { provider, student, admin }

// نموذج الطالب
class Student extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final DateTime enrollmentDate;
  final List<String> enrolledCourses;
  final List<Certificate> certificates;
  final StudentStatus status;

  const Student({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.enrollmentDate,
    this.enrolledCourses = const [],
    this.certificates = const [],
    this.status = StudentStatus.active,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatar,
        enrollmentDate,
        enrolledCourses,
        certificates,
        status
      ];

  Student copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    DateTime? enrollmentDate,
    List<String>? enrolledCourses,
    List<Certificate>? certificates,
    StudentStatus? status,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      certificates: certificates ?? this.certificates,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'enrolledCourses': enrolledCourses,
      'certificates': certificates.map((c) => c.toJson()).toList(),
      'status': status.name,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      enrollmentDate: DateTime.parse(json['enrollmentDate']),
      enrolledCourses: List<String>.from(json['enrolledCourses'] ?? []),
      certificates: (json['certificates'] as List?)
              ?.map((c) => Certificate.fromJson(c))
              .toList() ??
          [],
      status: StudentStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }
}

enum StudentStatus { active, inactive, suspended }

// نموذج الدورة
class Course extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? image;
  final String? imageUrl;
  final String providerId;
  final String providerName;
  final double price;
  final bool isFree;
  final CourseStatus status;
  final CourseLevel level;
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final int duration; // بالدقائق
  final int studentsCount;
  final double rating;
  final int reviewsCount;
  final List<Lesson> lessons;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.imageUrl,
    required this.providerId,
    required this.providerName,
    required this.price,
    this.isFree = false,
    this.status = CourseStatus.draft,
    required this.level,
    required this.category,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    required this.duration,
    this.studentsCount = 0,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.lessons = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        image,
        imageUrl,
        providerId,
        providerName,
        price,
        isFree,
        status,
        level,
        category,
        tags,
        createdAt,
        updatedAt,
        publishedAt,
        duration,
        studentsCount,
        rating,
        reviewsCount,
        lessons
      ];

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    String? imageUrl,
    String? providerId,
    String? providerName,
    double? price,
    bool? isFree,
    CourseStatus? status,
    CourseLevel? level,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    int? duration,
    int? studentsCount,
    double? rating,
    int? reviewsCount,
    List<Lesson>? lessons,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      status: status ?? this.status,
      level: level ?? this.level,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      duration: duration ?? this.duration,
      studentsCount: studentsCount ?? this.studentsCount,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      lessons: lessons ?? this.lessons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'providerId': providerId,
      'providerName': providerName,
      'price': price,
      'isFree': isFree,
      'status': status.name,
      'level': level.name,
      'category': category,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'duration': duration,
      'studentsCount': studentsCount,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      price: json['price']?.toDouble() ?? 0.0,
      isFree: json['isFree'] ?? false,
      status: CourseStatus.values.firstWhere((e) => e.name == json['status']),
      level: CourseLevel.values.firstWhere((e) => e.name == json['level']),
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      duration: json['duration'] ?? 0,
      studentsCount: json['studentsCount'] ?? 0,
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewsCount: json['reviewsCount'] ?? 0,
      lessons:
          (json['lessons'] as List?)?.map((l) => Lesson.fromJson(l)).toList() ??
              [],
    );
  }
}

enum CourseStatus { draft, pending, published, rejected, archived }

enum CourseLevel { beginner, intermediate, advanced }

// نموذج الدرس
class Lesson extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? videoUrl;
  final String? content;
  final int duration; // بالدقائق
  final int order;
  final bool isPreview;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    this.videoUrl,
    this.content,
    required this.duration,
    required this.order,
    this.isPreview = false,
  });

  @override
  List<Object?> get props =>
      [id, title, description, videoUrl, content, duration, order, isPreview];

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? content,
    int? duration,
    int? order,
    bool? isPreview,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      content: content ?? this.content,
      duration: duration ?? this.duration,
      order: order ?? this.order,
      isPreview: isPreview ?? this.isPreview,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'content': content,
      'duration': duration,
      'order': order,
      'isPreview': isPreview,
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['videoUrl'],
      content: json['content'],
      duration: json['duration'] ?? 0,
      order: json['order'] ?? 0,
      isPreview: json['isPreview'] ?? false,
    );
  }
}

// نموذج الشهادة
class Certificate extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String courseId;
  final String courseTitle;
  final DateTime issuedAt;
  final String certificateUrl;
  final CertificateStatus status;

  const Certificate({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseTitle,
    required this.issuedAt,
    required this.certificateUrl,
    this.status = CertificateStatus.active,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        studentName,
        courseId,
        courseTitle,
        issuedAt,
        certificateUrl,
        status
      ];

  Certificate copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? courseId,
    String? courseTitle,
    DateTime? issuedAt,
    String? certificateUrl,
    CertificateStatus? status,
  }) {
    return Certificate(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      courseId: courseId ?? this.courseId,
      courseTitle: courseTitle ?? this.courseTitle,
      issuedAt: issuedAt ?? this.issuedAt,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'issuedAt': issuedAt.toIso8601String(),
      'certificateUrl': certificateUrl,
      'status': status.name,
    };
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      courseId: json['courseId'],
      courseTitle: json['courseTitle'],
      issuedAt: DateTime.parse(json['issuedAt']),
      certificateUrl: json['certificateUrl'],
      status:
          CertificateStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }
}

enum CertificateStatus { active, revoked, expired }

// نموذج الإحصائيات
class Statistics extends Equatable {
  final int totalCourses;
  final int publishedCourses;
  final int totalStudents;
  final int activeStudents;
  final double totalRevenue;
  final double monthlyRevenue;
  final int totalCertificates;
  final double averageRating;

  const Statistics({
    this.totalCourses = 0,
    this.publishedCourses = 0,
    this.totalStudents = 0,
    this.activeStudents = 0,
    this.totalRevenue = 0.0,
    this.monthlyRevenue = 0.0,
    this.totalCertificates = 0,
    this.averageRating = 0.0,
  });

  @override
  List<Object?> get props => [
        totalCourses,
        publishedCourses,
        totalStudents,
        activeStudents,
        totalRevenue,
        monthlyRevenue,
        totalCertificates,
        averageRating
      ];

  Statistics copyWith({
    int? totalCourses,
    int? publishedCourses,
    int? totalStudents,
    int? activeStudents,
    double? totalRevenue,
    double? monthlyRevenue,
    int? totalCertificates,
    double? averageRating,
  }) {
    return Statistics(
      totalCourses: totalCourses ?? this.totalCourses,
      publishedCourses: publishedCourses ?? this.publishedCourses,
      totalStudents: totalStudents ?? this.totalStudents,
      activeStudents: activeStudents ?? this.activeStudents,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      totalCertificates: totalCertificates ?? this.totalCertificates,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCourses': totalCourses,
      'publishedCourses': publishedCourses,
      'totalStudents': totalStudents,
      'activeStudents': activeStudents,
      'totalRevenue': totalRevenue,
      'monthlyRevenue': monthlyRevenue,
      'totalCertificates': totalCertificates,
      'averageRating': averageRating,
    };
  }

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalCourses: json['totalCourses'] ?? 0,
      publishedCourses: json['publishedCourses'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      activeStudents: json['activeStudents'] ?? 0,
      totalRevenue: json['totalRevenue']?.toDouble() ?? 0.0,
      monthlyRevenue: json['monthlyRevenue']?.toDouble() ?? 0.0,
      totalCertificates: json['totalCertificates'] ?? 0,
      averageRating: json['averageRating']?.toDouble() ?? 0.0,
    );
  }
}

// نموذج الإعدادات
class AppSettings extends Equatable {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final String language;
  final String theme;
  final bool autoSave;

  const AppSettings({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.language = 'ar',
    this.theme = 'light',
    this.autoSave = true,
  });

  @override
  List<Object?> get props => [
        notificationsEnabled,
        emailNotifications,
        pushNotifications,
        language,
        theme,
        autoSave
      ];

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    String? language,
    String? theme,
    bool? autoSave,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      autoSave: autoSave ?? this.autoSave,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'language': language,
      'theme': theme,
      'autoSave': autoSave,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      language: json['language'] ?? 'ar',
      theme: json['theme'] ?? 'light',
      autoSave: json['autoSave'] ?? true,
    );
  }
}
