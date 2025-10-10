import '../models/index.dart';

class MockData {
  // بيانات وهمية للدورات
  static List<Course> get mockCourses => [
        Course(
          id: '1',
          title: 'أساسيات البرمجة بلغة Python',
          description:
              'دورة شاملة لتعلم أساسيات البرمجة باستخدام لغة Python من الصفر حتى الاحتراف',
          image:
              'https://via.placeholder.com/300x200/0C1445/FFFFFF?text=Python',
          providerId: '1',
          providerName: 'مقدم الخدمة التعليمية',
          price: 299.99,
          isFree: false,
          status: CourseStatus.published,
          level: CourseLevel.beginner,
          category: 'البرمجة',
          tags: const ['Python', 'البرمجة', 'المبتدئين'],
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 25)),
          publishedAt: DateTime.now().subtract(const Duration(days: 25)),
          duration: 1200, // 20 ساعة
          studentsCount: 150,
          rating: 4.5,
          reviewsCount: 45,
          lessons: [
            Lesson(
              id: '1',
              title: 'مقدمة في البرمجة',
              description: 'تعرف على أساسيات البرمجة ولغة Python',
              videoUrl: 'https://example.com/video1.mp4',
              duration: 60,
              order: 1,
              createdAt: DateTime.now(),
            ),
            Lesson(
              id: '2',
              title: 'المتغيرات وأنواع البيانات',
              description:
                  'تعلم كيفية استخدام المتغيرات وأنواع البيانات المختلفة',
              videoUrl: 'https://example.com/video2.mp4',
              duration: 90,
              order: 2,
              createdAt: DateTime.now(),
            ),
          ],
        ),
        Course(
          id: '2',
          title: 'تطوير تطبيقات الويب باستخدام React',
          description:
              'تعلم كيفية بناء تطبيقات ويب تفاعلية باستخدام مكتبة React',
          image: 'https://via.placeholder.com/300x200/F9D71C/0C1445?text=React',
          providerId: '1',
          providerName: 'مقدم الخدمة التعليمية',
          price: 0,
          isFree: true,
          status: CourseStatus.published,
          level: CourseLevel.intermediate,
          category: 'تطوير الويب',
          tags: const ['React', 'JavaScript', 'تطوير الويب'],
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 15)),
          publishedAt: DateTime.now().subtract(const Duration(days: 15)),
          duration: 900, // 15 ساعة
          studentsCount: 89,
          rating: 4.2,
          reviewsCount: 23,
          lessons: [
            Lesson(
              id: '3',
              title: 'مقدمة في React',
              description: 'تعرف على مكتبة React وأساسياتها',
              videoUrl: 'https://example.com/video3.mp4',
              duration: 45,
              order: 1,
              createdAt: DateTime.now(),
            ),
          ],
        ),
        Course(
          id: '3',
          title: 'تصميم واجهات المستخدم UX/UI',
          description: 'دورة متقدمة في تصميم تجربة المستخدم وواجهات التطبيقات',
          image: 'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=UX/UI',
          providerId: '1',
          providerName: 'مقدم الخدمة التعليمية',
          price: 199.99,
          isFree: false,
          status: CourseStatus.draft,
          level: CourseLevel.advanced,
          category: 'التصميم',
          tags: const ['UX', 'UI', 'التصميم', 'Figma'],
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 8)),
          duration: 720, // 12 ساعة
          studentsCount: 0,
          rating: 0,
          reviewsCount: 0,
          lessons: const [],
        ),
        Course(
          id: '4',
          title: 'إدارة قواعد البيانات MySQL',
          description: 'تعلم كيفية تصميم وإدارة قواعد البيانات باستخدام MySQL',
          image: 'https://via.placeholder.com/300x200/2196F3/FFFFFF?text=MySQL',
          providerId: '1',
          providerName: 'مقدم الخدمة التعليمية',
          price: 149.99,
          isFree: false,
          status: CourseStatus.pending,
          level: CourseLevel.intermediate,
          category: 'قواعد البيانات',
          tags: const ['MySQL', 'قواعد البيانات', 'SQL'],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          duration: 600, // 10 ساعات
          studentsCount: 0,
          rating: 0,
          reviewsCount: 0,
          lessons: const [],
        ),
        Course(
          id: '5',
          title: 'الذكاء الاصطناعي للمبتدئين',
          description: 'مقدمة شاملة في عالم الذكاء الاصطناعي وتطبيقاته',
          image: 'https://via.placeholder.com/300x200/F44336/FFFFFF?text=AI',
          providerId: '1',
          providerName: 'مقدم الخدمة التعليمية',
          price: 399.99,
          isFree: false,
          status: CourseStatus.published,
          level: CourseLevel.beginner,
          category: 'الذكاء الاصطناعي',
          tags: const ['AI', 'الذكاء الاصطناعي', 'Machine Learning'],
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now().subtract(const Duration(days: 40)),
          publishedAt: DateTime.now().subtract(const Duration(days: 40)),
          duration: 1800, // 30 ساعة
          studentsCount: 234,
          rating: 4.8,
          reviewsCount: 67,
          lessons: const [],
        ),
      ];

  // بيانات وهمية للطلاب
  static List<Student> get mockStudents => [
        Student(
          id: '1',
          name: 'أحمد محمد علي',
          email: 'ahmed@example.com',
          phone: '+966501234567',
          avatar: 'https://via.placeholder.com/150/0C1445/FFFFFF?text=أ',
          enrollmentDate: DateTime.now().subtract(const Duration(days: 60)),
          enrolledCourses: const ['1', '2'],
          certificateIds: const ['1'],
          status: StudentStatus.active,
        ),
        Student(
          id: '2',
          name: 'فاطمة أحمد السالم',
          email: 'fatima@example.com',
          phone: '+966507654321',
          avatar: 'https://via.placeholder.com/150/F9D71C/0C1445?text=ف',
          enrollmentDate: DateTime.now().subtract(const Duration(days: 45)),
          enrolledCourses: const ['1', '5'],
          certificateIds: const [],
          status: StudentStatus.active,
        ),
        Student(
          id: '3',
          name: 'محمد عبدالله الخالد',
          email: 'mohammed@example.com',
          phone: '+966509876543',
          avatar: 'https://via.placeholder.com/150/4CAF50/FFFFFF?text=م',
          enrollmentDate: DateTime.now().subtract(const Duration(days: 30)),
          enrolledCourses: const ['2'],
          certificateIds: const [],
          status: StudentStatus.active,
        ),
        Student(
          id: '4',
          name: 'نورا سعد المطيري',
          email: 'nora@example.com',
          phone: '+966502468135',
          avatar: 'https://via.placeholder.com/150/2196F3/FFFFFF?text=ن',
          enrollmentDate: DateTime.now().subtract(const Duration(days: 15)),
          enrolledCourses: const ['1'],
          certificateIds: const [],
          status: StudentStatus.active,
        ),
        Student(
          id: '5',
          name: 'خالد عبدالرحمن النصار',
          email: 'khalid@example.com',
          phone: '+966503691470',
          avatar: 'https://via.placeholder.com/150/F44336/FFFFFF?text=خ',
          enrollmentDate: DateTime.now().subtract(const Duration(days: 90)),
          enrolledCourses: const ['1', '2', '5'],
          certificateIds: const ['2'],
          status: StudentStatus.inactive,
        ),
      ];

  // بيانات وهمية للشهادات
  static List<Certificate> get mockCertificates => [
        Certificate(
          id: '1',
          studentId: '1',
          studentName: 'أحمد محمد علي',
          courseId: '1',
          courseName: 'أساسيات البرمجة بلغة Python',
          providerId: '1',
          providerName: 'أكاديمية التقنية',
          issuedAt: DateTime.now().subtract(const Duration(days: 10)),
          certificateUrl: 'https://example.com/certificates/cert1.pdf',
          status: CertificateStatus.active,
        ),
        Certificate(
          id: '2',
          studentId: '5',
          studentName: 'خالد عبدالرحمن النصار',
          courseId: '2',
          courseName: 'تطوير تطبيقات الويب باستخدام React',
          providerId: '1',
          providerName: 'أكاديمية التقنية',
          issuedAt: DateTime.now().subtract(const Duration(days: 20)),
          certificateUrl: 'https://example.com/certificates/cert2.pdf',
          status: CertificateStatus.active,
        ),
        Certificate(
          id: '3',
          studentId: '2',
          studentName: 'فاطمة أحمد السالم',
          courseId: '5',
          courseName: 'الذكاء الاصطناعي للمبتدئين',
          providerId: '1',
          providerName: 'أكاديمية التقنية',
          issuedAt: DateTime.now().subtract(const Duration(days: 5)),
          certificateUrl: 'https://example.com/certificates/cert3.pdf',
          status: CertificateStatus.active,
        ),
      ];

  // بيانات وهمية للمستخدم
  static User get mockUser => User(
        id: '1',
        name: 'مقدم الخدمة التعليمية',
        email: 'provider@wasla.com',
        phone: '+966501234567',
        avatar: 'https://via.placeholder.com/150/0C1445/FFFFFF?text=و',
        type: UserType.provider,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        isActive: true,
      );

  // بيانات وهمية للإعدادات
  static AppSettings get mockSettings => const AppSettings(
        notificationsEnabled: true,
        emailNotifications: true,
        pushNotifications: false,
        language: 'ar',
        theme: 'light',
        autoSave: true,
      );

  // فئات الدورات
  static List<String> get courseCategories => [
        'البرمجة',
        'تطوير الويب',
        'تطوير التطبيقات',
        'التصميم',
        'قواعد البيانات',
        'الذكاء الاصطناعي',
        'الأمن السيبراني',
        'إدارة المشاريع',
        'التسويق الرقمي',
        'اللغات',
        'العلوم',
        'الرياضيات',
        'الفيزياء',
        'الكيمياء',
        'الأحياء',
        'التاريخ',
        'الجغرافيا',
        'الأدب',
        'الفلسفة',
        'علم النفس',
      ];

  // العلامات الشائعة
  static List<String> get popularTags => [
        'Python',
        'JavaScript',
        'React',
        'Flutter',
        'Node.js',
        'HTML',
        'CSS',
        'SQL',
        'MongoDB',
        'Firebase',
        'AWS',
        'Docker',
        'Git',
        'API',
        'Mobile',
        'Web',
        'Frontend',
        'Backend',
        'Fullstack',
        'UI/UX',
        'Design',
        'Photoshop',
        'Illustrator',
        'Figma',
        'Machine Learning',
        'Deep Learning',
        'Data Science',
        'Analytics',
        'Blockchain',
        'Cryptocurrency',
      ];

  // بيانات الرسوم البيانية
  static List<Map<String, dynamic>> get chartData => [
        {'month': 'يناير', 'students': 45, 'revenue': 2500},
        {'month': 'فبراير', 'students': 52, 'revenue': 2800},
        {'month': 'مارس', 'students': 38, 'revenue': 2200},
        {'month': 'أبريل', 'students': 67, 'revenue': 3400},
        {'month': 'مايو', 'students': 73, 'revenue': 3800},
        {'month': 'يونيو', 'students': 89, 'revenue': 4200},
        {'month': 'يوليو', 'students': 95, 'revenue': 4600},
        {'month': 'أغسطس', 'students': 82, 'revenue': 4100},
        {'month': 'سبتمبر', 'students': 76, 'revenue': 3900},
        {'month': 'أكتوبر', 'students': 91, 'revenue': 4500},
        {'month': 'نوفمبر', 'students': 103, 'revenue': 5200},
        {'month': 'ديسمبر', 'students': 118, 'revenue': 5800},
      ];

  // إشعارات وهمية
  static List<Map<String, dynamic>> get mockNotifications => [
        {
          'id': '1',
          'title': 'طالب جديد انضم للدورة',
          'message': 'انضم أحمد محمد إلى دورة أساسيات البرمجة بلغة Python',
          'type': 'student',
          'time': DateTime.now().subtract(const Duration(minutes: 30)),
          'isRead': false,
        },
        {
          'id': '2',
          'title': 'تقييم جديد',
          'message': 'حصلت على تقييم 5 نجوم من فاطمة أحمد على دورة React',
          'type': 'review',
          'time': DateTime.now().subtract(const Duration(hours: 2)),
          'isRead': false,
        },
        {
          'id': '3',
          'title': 'دفعة جديدة',
          'message': 'تم استلام دفعة بقيمة 299.99 ريال من بيع الدورات',
          'type': 'payment',
          'time': DateTime.now().subtract(const Duration(hours: 5)),
          'isRead': true,
        },
        {
          'id': '4',
          'title': 'تحديث النظام',
          'message': 'تم تحديث النظام إلى الإصدار الجديد بميزات محسنة',
          'type': 'system',
          'time': DateTime.now().subtract(const Duration(days: 1)),
          'isRead': true,
        },
      ];

  // طرق الدفع الوهمية
  static List<Map<String, dynamic>> get paymentMethods => [
        {
          'id': 'visa',
          'name': 'بطاقة فيزا',
          'icon': 'credit_card',
          'description': 'الدفع بواسطة بطاقة فيزا الائتمانية',
          'enabled': true,
        },
        {
          'id': 'mastercard',
          'name': 'بطاقة ماستركارد',
          'icon': 'credit_card',
          'description': 'الدفع بواسطة بطاقة ماستركارد الائتمانية',
          'enabled': true,
        },
        {
          'id': 'mada',
          'name': 'بطاقة مدى',
          'icon': 'payment',
          'description': 'الدفع بواسطة بطاقة مدى السعودية',
          'enabled': true,
        },
        {
          'id': 'stc_pay',
          'name': 'STC Pay',
          'icon': 'mobile_friendly',
          'description': 'الدفع بواسطة محفظة STC Pay الرقمية',
          'enabled': false,
        },
        {
          'id': 'apple_pay',
          'name': 'Apple Pay',
          'icon': 'phone_iphone',
          'description': 'الدفع بواسطة Apple Pay',
          'enabled': false,
        },
      ];

  // الأسئلة الشائعة
  static List<Map<String, String>> get faqData => [
        {
          'question': 'كيف يمكنني إنشاء دورة جديدة؟',
          'answer':
              'يمكنك إنشاء دورة جديدة من خلال الذهاب إلى قسم "الدورات" والنقر على زر "إضافة دورة جديدة".',
        },
        {
          'question': 'كيف يتم احتساب الأرباح؟',
          'answer':
              'يتم احتساب الأرباح بناءً على عدد الطلاب المسجلين في دوراتك وأسعار الدورات.',
        },
        {
          'question': 'متى يتم صرف الأرباح؟',
          'answer':
              'يتم صرف الأرباح شهرياً في نهاية كل شهر إلى الحساب البنكي المسجل.',
        },
        {
          'question': 'كيف يمكنني تتبع أداء دوراتي؟',
          'answer':
              'يمكنك تتبع أداء دوراتك من خلال لوحة التحكم التي تعرض إحصائيات مفصلة.',
        },
        {
          'question': 'هل يمكنني تعديل محتوى الدورة بعد نشرها؟',
          'answer':
              'نعم، يمكنك تعديل محتوى الدورة في أي وقت، ولكن التغييرات الكبيرة قد تحتاج لمراجعة.',
        },
      ];

  // معلومات الدعم الفني
  static Map<String, dynamic> get supportInfo => {
        'email': 'support@wasla.com',
        'phone': '+966920000000',
        'whatsapp': '+966501234567',
        'workingHours': 'الأحد - الخميس: 9:00 ص - 6:00 م',
        'responseTime': '24 ساعة',
      };

  // روابط التواصل الاجتماعي
  static Map<String, String> get socialLinks => {
        'twitter': 'https://twitter.com/wasla_platform',
        'instagram': 'https://instagram.com/wasla_platform',
        'linkedin': 'https://linkedin.com/company/wasla-platform',
        'youtube': 'https://youtube.com/c/wasla-platform',
        'facebook': 'https://facebook.com/wasla.platform',
      };
}
