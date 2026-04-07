# 📊 تعليمات إعداد قاعدة البيانات - منصة Wasla

## 🎯 الخطوات المطلوبة

### الخطوة 1: الحصول على بيانات Supabase

1. اذهب إلى [Supabase Dashboard](https://app.supabase.com)
2. اختر مشروعك (أو أنشئ مشروع جديد)
3. اذهب إلى **Settings** → **API**
4. انسخ:
   - **Project URL** (مثال: `https://your-project.supabase.co`)
   - **anon public** (المفتاح العام)
   - **service_role** (مفتاح الخدمة - للاستخدام الخادم فقط)

### الخطوة 2: تحديث ملف الإعدادات

1. افتح `lib/config/supabase_config.dart`
2. استبدل القيم:
   ```dart
   static const String supabaseUrl = 'https://your-project.supabase.co';
   static const String supabaseAnonKey = 'your-anon-key';
   ```

### الخطوة 3: تنفيذ SQL Scripts

#### الطريقة 1: استخدام Supabase SQL Editor (الأسهل)

1. اذهب إلى Supabase Dashboard
2. اختر **SQL Editor** من القائمة الجانبية
3. انقر على **New Query**
4. انسخ محتوى ملف `database/init.sql`
5. الصق المحتوى في محرر SQL
6. انقر على **Run** (أو اضغط `Ctrl+Enter`)
7. تحقق من أن جميع الجداول تم إنشاؤها بنجاح

#### الطريقة 2: استخدام Supabase CLI

```bash
# تثبيت Supabase CLI
npm install -g supabase

# تسجيل الدخول
supabase login

# تنفيذ SQL Scripts
supabase db push
```

### الخطوة 4: إنشاء Buckets للتخزين

1. اذهب إلى **Storage** في Supabase Dashboard
2. انقر على **Create a new bucket** لكل من:
   - `course-videos` (للفيديوهات)
   - `course-files` (للملفات)
   - `course-images` (للصور)
   - `certificates` (للشهادات)
   - `avatars` (للصور الشخصية)

3. لكل bucket:
   - اختر **Public** إذا كنت تريد الوصول العام
   - أو **Private** للوصول المحدود

### الخطوة 5: تكوين سياسات الأمان للـ Buckets

1. اذهب إلى **Storage** → **Policies**
2. أضف سياسات للقراءة والكتابة حسب الحاجة

### الخطوة 6: تحديث pubspec.yaml

تأكد من إضافة الحزم المطلوبة:

```yaml
dependencies:
  supabase_flutter: ^2.5.0
  supabase: ^2.5.0
```

ثم قم بتشغيل:
```bash
flutter pub get
```

### الخطوة 7: اختبار الاتصال

1. افتح `lib/main.dart`
2. تأكد من تهيئة Supabase:
   ```dart
   await Supabase.initialize(
     url: SupabaseConfig.supabaseUrl,
     anonKey: SupabaseConfig.supabaseAnonKey,
   );
   ```

3. قم بتشغيل التطبيق:
   ```bash
   flutter run
   ```

---

## ✅ قائمة التحقق

- [ ] تم الحصول على بيانات Supabase
- [ ] تم تحديث `supabase_config.dart`
- [ ] تم تنفيذ SQL Scripts
- [ ] تم إنشاء جميع الجداول (15 جدول)
- [ ] تم تفعيل RLS على جميع الجداول
- [ ] تم إنشاء Buckets (5 buckets)
- [ ] تم تحديث `pubspec.yaml`
- [ ] تم اختبار الاتصال

---

## 🔐 الأمان

### نصائح مهمة:

1. **لا تشارك مفاتيحك**: لا تضع مفاتيح Supabase في الكود العام
2. **استخدم متغيرات البيئة**: استخدم `.env` أو متغيرات البيئة
3. **RLS مفعل**: جميع الجداول محمية بـ Row Level Security
4. **Buckets آمنة**: استخدم سياسات الأمان للـ Buckets

---

## 📝 ملاحظات

- جميع الجداول تحتوي على فهارس لتحسين الأداء
- جميع الجداول محمية بـ RLS
- تم إنشاء Triggers تلقائية لتحديث الإحصائيات
- جميع العلاقات بين الجداول محددة بـ Foreign Keys

---

## 🆘 استكشاف الأخطاء

### خطأ: "Permission denied"
- تحقق من أن RLS مفعل بشكل صحيح
- تحقق من سياسات الأمان

### خطأ: "Table does not exist"
- تأكد من تنفيذ SQL Scripts بالكامل
- تحقق من أسماء الجداول

### خطأ: "Invalid API key"
- تحقق من أن المفتاح صحيح
- تأكد من أنك تستخدم المفتاح العام (anon key)

---

## 📞 الدعم

للمزيد من المعلومات، راجع:
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Guide](https://supabase.com/docs/reference/flutter/introduction)
- ملفات المشروع المرجعية في `.kiro/steering/`

---

**تم إعداد كل شيء! ابدأ الآن بتنفيذ SQL Scripts 🚀**
