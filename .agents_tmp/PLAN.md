# 1. OBJECTIVE

إعادة بناء تطبيق Next.js ليكون نسخة مطابقة تماماً من تطبيق Flutter الموجود في الـ main branch، مع تحسينات شاملة وتجهيزه للنشر على Vercel.

**الهدف النهائي:** الحصول على تطبيق ويب احترافي مدراء الكورسات (Provider Dashboard) مطابق تصميماً ومنطقاً لتطبيق Flutter، مع عمل كامل للنشر.

---

# 2. CONTEXT SUMMARY

## المشروع الحالي:
- **تطبيق Flutter:** مشروع متكامل بمجلد `lib/` يحوي كامل المنطق والواجهة
- **تطبيق Next.js:** مشروع موجود في مجلد `nextjs-dashboard/` ويحتاج إعادة بناء
- **قاعدة البيانات:** ملف `database/wasla_full_database.sql` يحوي完整的 الجداول

## الألوان والتصميم:
- Primary: `#0C1445` (Dark Blue)
- Secondary: `#FFD54F` (Gold/Yellow)
- Font: Tajawal/Cairo (RTL)
- تصميم Material 3 مع دعم RTL

## الصفحات في تطبيق Flutter:
1. **لوحة التحكم (Dashboard):** إحصائيات - الكورسات - الطلاب - الشهادات - المدفوعات
2. **الكورسات (Courses):** إضافة - تعديل - حذف - نشر - محتوى - طلاب - شهادات - امتحانات
3. **الشهادات (Certificates):** إنشاء قالب - إصدار شهادة - إدارة
4. **المدفوعات (Payments):** المدفوعات - الإعدادات - الأرباح
5. **الإعدادات (Settings):** عام - إشعارات - حساب - دفع -关于我们

---

# 3. APPROACH OVERVIEW

## الاستراتيجية:
1. **مرحلة تحليل شاملة:** دراسة تطبيق Flutter واستخراج كل التفاصيل
2. **مرحلة إعادة التصميم:** تطبيق نفس التصميم والألوان في Next.js
3. **مرحلة التطوير:** بناء كل الصفحات والميزات بشكل كامل
4. **مرحلة التكامل:** ربط قاعدة البيانات بشكل صحيح
5. **مرحلة الاختبار:** اختبار كل العمليات
6. **مرحلة النشر:** تهيئة للنشر على Vercel

## لماذا هذا الأسلوب:
- تطبيق Flutter يحتوي على كل المتطلبات والميزات
- قاعدة البيانات محددة ويمكن البناء عليها
- Tailwind CSS موجود ويمكن تخصيصه للألوان المطلوبة

---

# 4. IMPLEMENTATION STEPS

## المرحلة الأولى: التحليل والاستخراج (البدء بها)

### الخطوة 1.1: استخراج Theme والألوان
- **الهدف:** تطبيق نفس الـ Theme في Next.js
- **الطريقة:** تحديث Tailwind config لتطابق ألوان Flutter
- **المرجع:** `lib/core/theme/app_theme.dart` → `tailwind.config.js`

### الخطوة 1.2: استخراج Types والـ Models
- **الهدف:** إنشاء TypeScript interfaces مطابقة
- **الطريقة:** تحويل Dart models إلى TypeScript
- **المرجع:** `lib/data/models/*.dart` → `src/types/index.ts`

### الخطوة 1.3: استخراج الخدمات (Services)
- **الهدف:** بناء API functions للنقاط النهاية
- **الطريقة:** تحويل خدمات Flutter إلى functions
- **المرجع:** `lib/data/services/*.dart` → `src/lib/services.ts`

### الخطوة 1.4: استخراج الـ State Management
- **الهدف:** إعداد Zustand stores للـ State
- **الطريقة:** تحويل BLoC pattern إلى Zustand
- **المرجع:** `lib/presentation/blocs/*.dart` → `src/lib/store.ts`

---

## المرحلة الثانية: إعادة بناء الواجهات

### الخطوة 2.1: إعادة بناء Dashboard (الرئيسية)
- **الهدف:** صفحة لوحة التحكم بالـ Stats
- **الطريقة:** تطبيق نفس Layout والتصميم
- **المرجع:** `lib/presentation/screens/dashboard_screen.dart`

### الخطوة 2.2: إعادة بناء Courses (إدارة الكورسات)
- **الهدف:** صفحة قائمة الكورسات + إضافة/تعديل
- **الطريقة:** نفس التصميم مع دعم CRUD كامل
- **المرجع:** `lib/presentation/screens/course_screen.dart`

### الخطوة 2.3: إعادة بناء Course Content (محتوى الكورس)
- **الهدف:** إضافة Modules + Lessons + Files
- **الطريقة:** نفس UI مع drag-drop pentru Modules
- **المرجع:** `lib/presentation/screens/course_content_management_screen.dart`

### الخطوة 2.4: إعادة بناء Exams (الامتحانات)
- **الهدف:** إنشاء + إدارة أسئلة الامتحانات
- **الطريقة:** نفس الـ Flow والتصميم
- **المرجع:** `lib/presentation/screens/exam_management_screen.dart`

### الخطوة 2.5: إعادة بناء Certificates (الشهادات)
- **الهدف:** إصدار + قوالب الشهادات
- **الطريقة:** نفس UI مع PDF generation
- **المرجع:** `lib/presentation/screens/all_certificates_screen.dart`

### الخطوة 2.6: إعادة بناء Payments (المدفوعات)
- **الهدف:** صفحة المدفوعات والإعدادات
- **الطريقة:** نفس Layout والـ Stats
- **المرجع:** `lib/presentation/screens/payments_screen.dart`

### الخطوة 2.7: إعادة بناء Settings (الإعدادات)
- **الهدف:** 5 tabs: عام - إشعارات - حساب - دفع - عن
- **الطريقة:** نفس UI مع كامل الإعدادات
- **المرجع:** `lib/presentation/screens/settings_screen.dart`

### الخطوة 2.8: إعادة بناء Students (الطلاب)
- **الهدف:** عرض طلاب كل كورس
- **الطريقة:** نفس البطاقات والـ Actions
- **المرجع:** `lib/presentation/screens/course_students_screen.dart`

---

## المرحلة الثالثة: إصلاح قاعدة البيانات

### الخطوة 3.1: تحسين CRUD Operations
- **الهدف:** التأكد من صحة كل العمليات
- **الطريقة:** مراجعة كل function وتحديثها

### الخطوة 3.2: معالجة الأخطاء
- **الهدف:** إضافة proper error handling
- **الطريقة:** Try-catch + user-friendly messages

### الخطوة 3.3: تنظيم الـ API
- **الهدف:** إنشاء API routes للنقاط المعقدة
- **الطريقة:** Next.js API routes في `src/app/api/`

---

## المرحلة الرابعة: التحسينات

### الخطوة 4.1: تحسين الأداء
- **الهدف:** جعل التطبيق سريعاً
- **الطريقة:** React Query + caching + lazy loading

### الخطوة 4.2: تحسين UX
- **الهدف:** تجربة مستخدم أفضل
- **الطريقة:** Loading states + transitions + feedback

---

## المرحلة الخامسة: الاختبار والمحاكاة

### الخطوة 5.1: اختبار تسجيل الدخول
- **الهدف:** تسجيل الدخول بالبيانات المعطاة
- **البيانات:**
  - Email: fhmyalamry990@gmail.com
  - Password: aswasw1234

### الخطوة 5.2: اختبار العمليات
- إضافة كورس جديد
- إضافة وحدات (Modules)
- رفع ملفات وفيديوهات
- إنشاء اختبار (Exam)
- إصدار شهادة (Certificate)
- إدخال بيانات الدفع

---

## المرحلة السادسة: النشر على Vercel

### الخطوة 6.1: إعداد Environment Variables
- **الهدف:** إضافة المتغيرات المطلوبة
- **المتغيرات:**
  - NEXT_PUBLIC_SUPABASE_URL
  - NEXT_PUBLIC_SUPABASE_ANON_KEY

### الخطوة 6.2: التحقق من Build
- **الهدف:** نجاح البناء بنسبة 100%
- **الأمر:** `npm run build`

### الخطوة 6.3: النشر
- **الهدف:** رفع على Vercel
- **الطريقة:** Vercel CLI أو Git integration

---

# 5. TESTING AND VALIDATION

## معايير النجاح:

### التصميم:
- ✅ نفس الألوان (Primary #0C1445, Secondary #FFD54F)
- ✅ نفس الخطوط (Tajawal/Cairo)
- ✅ نفس Layouts والمكونات
- ✅ دعم RTL كامل

### الوظائف:
- ✅ تسجيل الدخول يعمل
- ✅ إضافة/تعديل/حذف الكورسات
- ✅ إدارة Modules + Lessons + Files
- ✅ إنشاء وإدارة الامتحانات
- ✅ إصدار الشهادات
- ✅ عرض المدفوعات
- ✅ إعدادات الحساب

### النشر:
- ✅ Build ينجح 100%
- ✅ يعمل على Vercel بدون أخطاء
- ✅ Environment Variables صحيحة
