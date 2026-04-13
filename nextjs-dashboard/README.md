# Wasla Provider Dashboard - Production Ready

منصة تحكم مقدم خدمة الكورسات (Wasla) - نظام إدارة تعليمي متكامل جاهز للإطلاق.

## ✅ الميزات المنفذة

### 🔐 المصادقة
- تسجيل الدخول
- إنشاء حساب
- تغيير كلمة المرور

### 📚 إدارة الكورسات
- إنشاء كورس جديد
- تعديل بيانات الكورس
- حذف الكورس
- نشر / إلغاء نشر الكورس

### 📦 إدارة المحتوى
- إضافة/حذف الوحدات
- إضافة/حذف الدروس
- دعم أنواع المحتوى:
  - 🎬 فيديو (رفع أو رابط YouTube/Vimeo)
  - 📄 ملف PDF (رفع أو رابط)
  - 📝 نص
- Progress Bar لرفع الملفات

### 📝 نظام الاختبارات
- إنشاء امتحان
- إضافة أسئلة MCQ
- تحديد الإجابة الصحيحة
- التصحيح التلقائي
- عرض النتائج (ناجح/راسب)
- التحكم في عدد المحاولات

### 👨‍🎓 إدارة الطلاب
- عرض الطلاب المسجلين
- البحث عن طالب
- تصفية حسب الكورس
- عرض تفاصيل الطالب

### 🎓 إدارة الشهادات
- إصدار شهادة يدوي
- إلغاء الشهادة

### 💳 نظام المدفوعات
- نظرة عامة على الأرباح
- تأكيد/رفض المدفوعات
- سجل العمليات المالية

### ⚙️ الإعدادات
- الملف الشخصي
- تغيير كلمة المرور
- إعدادات الدفع

## 🛠️ التقنيات

- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS
- Supabase (Backend + Storage)
- Zustand (Global State)

## 🚀 طريقة التشغيل

```bash
npm install
npm run dev
```

## 📋 إعدادات Supabase

أنشئ ملف `.env.local`:
```
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

## 📁 هيكل المشروع

```
src/
├── app/              # الصفحات (App Router)
│   ├── auth/         # تسجيل الدخول/تسجيل
│   └── dashboard/    # لوحة التحكم
│       ├── courses/  # إدارة الكورسات
│       ├── students/# إدارة الطلاب
│       ├── certificates/
│       ├── payments/
│       └── settings/
├── components/        # المكونات
│   └── ui/           # مكونات UI
├── lib/              # الخدمات
│   ├── supabase.ts  # Supabase client
│   ├── services.ts   # API services
│   ├── store.ts     # Zustand store
│   └── utils.ts     # أدوات
└── types/           # TypeScript types
```

## 🎯 حالة النظام

**جاهز للإطلاق** ✅